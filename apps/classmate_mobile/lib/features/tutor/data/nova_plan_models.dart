import 'dart:math' as math;

enum NovaPlanId { free, plus, pro, school }

class NovaCostAssumptions {
  const NovaCostAssumptions({
    required this.modelLabel,
    required this.inputUsdPerMillion,
    required this.outputUsdPerMillion,
    required this.transcriptionUsdPerMinute,
    required this.avgPromptInputTokens,
    required this.avgPromptOutputTokens,
    required this.avgUploadInputTokens,
    required this.avgUploadOutputTokens,
  });

  final String modelLabel;
  final double inputUsdPerMillion;
  final double outputUsdPerMillion;
  final double transcriptionUsdPerMinute;
  final int avgPromptInputTokens;
  final int avgPromptOutputTokens;
  final int avgUploadInputTokens;
  final int avgUploadOutputTokens;

  double promptCostUsd() {
    return ((avgPromptInputTokens / 1000000) * inputUsdPerMillion) +
        ((avgPromptOutputTokens / 1000000) * outputUsdPerMillion);
  }

  double uploadCostUsd() {
    return ((avgUploadInputTokens / 1000000) * inputUsdPerMillion) +
        ((avgUploadOutputTokens / 1000000) * outputUsdPerMillion);
  }
}

const novaCostAssumptions = NovaCostAssumptions(
  modelLabel: 'claude-sonnet-4-6',
  inputUsdPerMillion: 3.00,
  outputUsdPerMillion: 15.00,
  transcriptionUsdPerMinute: 0.006,
  avgPromptInputTokens: 700,
  avgPromptOutputTokens: 1400,
  avgUploadInputTokens: 2200,
  avgUploadOutputTokens: 900,
);

class NovaPlanSpec {
  const NovaPlanSpec({
    required this.id,
    required this.name,
    required this.tagline,
    required this.monthlyPriceUsd,
    required this.monthlyPromptLimit,
    required this.monthlyUploadLimit,
    required this.monthlyVoiceMinutes,
    required this.featureBullets,
    required this.isPlaceholderCheckout,
  });

  final NovaPlanId id;
  final String name;
  final String tagline;
  final double monthlyPriceUsd;
  final int monthlyPromptLimit;
  final int monthlyUploadLimit;
  final int monthlyVoiceMinutes;
  final List<String> featureBullets;
  final bool isPlaceholderCheckout;

  bool get isFree => monthlyPriceUsd <= 0;

  double estimatedMonthlyCostUsd({
    required NovaCostAssumptions assumptions,
  }) {
    return (monthlyPromptLimit * assumptions.promptCostUsd()) +
        (monthlyUploadLimit * assumptions.uploadCostUsd()) +
        (monthlyVoiceMinutes * assumptions.transcriptionUsdPerMinute);
  }

  double grossMarginPercent({required NovaCostAssumptions assumptions}) {
    if (isFree) return 0;
    final cost = estimatedMonthlyCostUsd(assumptions: assumptions);
    if (monthlyPriceUsd <= 0) return 0;
    return ((monthlyPriceUsd - cost) / monthlyPriceUsd) * 100;
  }
}

const novaPlans = <NovaPlanSpec>[
  NovaPlanSpec(
    id: NovaPlanId.free,
    name: 'Starter',
    tagline: 'Enough for trial and light weekly revision.',
    monthlyPriceUsd: 0,
    monthlyPromptLimit: 40,
    monthlyUploadLimit: 6,
    monthlyVoiceMinutes: 10,
    isPlaceholderCheckout: true,
    featureBullets: <String>[
      '40 NOVA prompts each month',
      '6 image or file uploads',
      '10 voice transcription minutes',
    ],
  ),
  NovaPlanSpec(
    id: NovaPlanId.plus,
    name: 'Plus',
    tagline: 'Best for one serious student using NOVA most days.',
    monthlyPriceUsd: 9.99,
    monthlyPromptLimit: 600,
    monthlyUploadLimit: 40,
    monthlyVoiceMinutes: 120,
    isPlaceholderCheckout: true,
    featureBullets: <String>[
      '600 NOVA prompts each month',
      '40 image or file uploads',
      '120 voice transcription minutes',
    ],
  ),
  NovaPlanSpec(
    id: NovaPlanId.pro,
    name: 'Pro',
    tagline: 'Heavy daily use, full exam season, and long study sessions.',
    monthlyPriceUsd: 24.99,
    monthlyPromptLimit: 2500,
    monthlyUploadLimit: 150,
    monthlyVoiceMinutes: 360,
    isPlaceholderCheckout: true,
    featureBullets: <String>[
      '2,500 NOVA prompts each month',
      '150 image or file uploads',
      '360 voice transcription minutes',
    ],
  ),
  NovaPlanSpec(
    id: NovaPlanId.school,
    name: 'School Seat',
    tagline: 'For rollout per student or staff seat inside a real school.',
    monthlyPriceUsd: 79.0,
    monthlyPromptLimit: 10000,
    monthlyUploadLimit: 600,
    monthlyVoiceMinutes: 1200,
    isPlaceholderCheckout: true,
    featureBullets: <String>[
      '10,000 NOVA prompts per seat monthly',
      '600 image or file uploads',
      '1,200 voice transcription minutes',
    ],
  ),
];

NovaPlanSpec novaPlanById(NovaPlanId id) {
  return novaPlans.firstWhere((plan) => plan.id == id);
}

class NovaUsageSnapshot {
  const NovaUsageSnapshot({
    required this.cycleKey,
    required this.promptsUsed,
    required this.uploadsUsed,
    required this.voiceMinutesUsed,
  });

  const NovaUsageSnapshot.empty(String cycleKey)
      : this(
          cycleKey: cycleKey,
          promptsUsed: 0,
          uploadsUsed: 0,
          voiceMinutesUsed: 0,
        );

  final String cycleKey;
  final int promptsUsed;
  final int uploadsUsed;
  final int voiceMinutesUsed;

  NovaUsageSnapshot copyWith({
    String? cycleKey,
    int? promptsUsed,
    int? uploadsUsed,
    int? voiceMinutesUsed,
  }) {
    return NovaUsageSnapshot(
      cycleKey: cycleKey ?? this.cycleKey,
      promptsUsed: promptsUsed ?? this.promptsUsed,
      uploadsUsed: uploadsUsed ?? this.uploadsUsed,
      voiceMinutesUsed: voiceMinutesUsed ?? this.voiceMinutesUsed,
    );
  }
}

String novaCurrentCycleKey([DateTime? now]) {
  final value = now ?? DateTime.now();
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month';
}

int novaRoundedVoiceMinutes(int seconds) {
  if (seconds <= 0) return 0;
  return math.max(1, (seconds / 60).ceil());
}