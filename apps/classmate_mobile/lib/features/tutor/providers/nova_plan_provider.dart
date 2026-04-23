import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/nova_plan_models.dart';

final novaPlanControllerProvider = Provider<NovaPlanController>((ref) {
  final controller = NovaPlanController();
  ref.onDispose(controller.dispose);
  return controller;
});

class NovaPlanController extends ChangeNotifier {
  static const _selectedPlanKey = 'nova_selected_plan_v1';
  static const _usageCycleKey = 'nova_usage_cycle_v1';
  static const _usagePromptsKey = 'nova_usage_prompts_v1';
  static const _usageUploadsKey = 'nova_usage_uploads_v1';
  static const _usageVoiceMinutesKey = 'nova_usage_voice_minutes_v1';

  NovaPlanController() {
    _load();
  }

  bool _ready = false;
  NovaPlanId _selectedPlanId = NovaPlanId.plus;
  NovaUsageSnapshot _usage = NovaUsageSnapshot.empty(novaCurrentCycleKey());

  bool get ready => _ready;
  NovaPlanId get selectedPlanId => _selectedPlanId;
  NovaPlanSpec get selectedPlan => novaPlanById(_selectedPlanId);
  NovaUsageSnapshot get usage => _usage;
  NovaCostAssumptions get assumptions => novaCostAssumptions;

  int get promptsRemaining =>
      (selectedPlan.monthlyPromptLimit - _usage.promptsUsed).clamp(
        0,
        selectedPlan.monthlyPromptLimit,
      );
  int get uploadsRemaining =>
      (selectedPlan.monthlyUploadLimit - _usage.uploadsUsed).clamp(
        0,
        selectedPlan.monthlyUploadLimit,
      );
  int get voiceMinutesRemaining =>
      (selectedPlan.monthlyVoiceMinutes - _usage.voiceMinutesUsed).clamp(
        0,
        selectedPlan.monthlyVoiceMinutes,
      );

  double get estimatedPlanCostUsd =>
      selectedPlan.estimatedMonthlyCostUsd(assumptions: assumptions);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPlan = prefs.getString(_selectedPlanKey) ?? '';
    final cycle = prefs.getString(_usageCycleKey) ?? novaCurrentCycleKey();
    final prompts = prefs.getInt(_usagePromptsKey) ?? 0;
    final uploads = prefs.getInt(_usageUploadsKey) ?? 0;
    final voice = prefs.getInt(_usageVoiceMinutesKey) ?? 0;

    _selectedPlanId = NovaPlanId.values.firstWhere(
      (value) => value.name == storedPlan,
      orElse: () => NovaPlanId.plus,
    );
    _usage = NovaUsageSnapshot(
      cycleKey: cycle,
      promptsUsed: prompts,
      uploadsUsed: uploads,
      voiceMinutesUsed: voice,
    );

    await _rolloverIfNeeded(prefs);
    _ready = true;
    notifyListeners();
  }

  Future<void> _rolloverIfNeeded(SharedPreferences prefs) async {
    final currentCycle = novaCurrentCycleKey();
    if (_usage.cycleKey == currentCycle) return;
    _usage = NovaUsageSnapshot.empty(currentCycle);
    await _persistUsage(prefs);
  }

  Future<void> _persistUsage(SharedPreferences prefs) async {
    await prefs.setString(_usageCycleKey, _usage.cycleKey);
    await prefs.setInt(_usagePromptsKey, _usage.promptsUsed);
    await prefs.setInt(_usageUploadsKey, _usage.uploadsUsed);
    await prefs.setInt(_usageVoiceMinutesKey, _usage.voiceMinutesUsed);
  }

  Future<void> selectPlan(NovaPlanId id) async {
    _selectedPlanId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPlanKey, id.name);
    notifyListeners();
  }

  bool canSendPrompt({int uploadCount = 0}) {
    return promptsRemaining >= 1 && uploadsRemaining >= uploadCount;
  }

  bool canUseVoiceMinutes(int seconds) {
    return voiceMinutesRemaining >= novaRoundedVoiceMinutes(seconds);
  }

  Future<void> recordPrompt({int uploadCount = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNeeded(prefs);
    _usage = _usage.copyWith(
      promptsUsed: _usage.promptsUsed + 1,
      uploadsUsed: _usage.uploadsUsed + uploadCount,
    );
    await _persistUsage(prefs);
    notifyListeners();
  }

  Future<void> recordVoiceUsage(int seconds) async {
    final roundedMinutes = novaRoundedVoiceMinutes(seconds);
    if (roundedMinutes <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNeeded(prefs);
    _usage = _usage.copyWith(
      voiceMinutesUsed: _usage.voiceMinutesUsed + roundedMinutes,
    );
    await _persistUsage(prefs);
    notifyListeners();
  }
}