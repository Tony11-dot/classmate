import {
  BadRequestException,
  HttpException,
  HttpStatus,
  InternalServerErrorException,
} from '@nestjs/common';

export type PracticeReasonCode =
  | 'UNSUPPORTED_TOPIC'
  | 'TOPIC_NEEDS_CLARIFICATION'
  | 'GENERATION_FAILED'
  | 'INVALID_REQUEST';

type PracticeErrorPayload = {
  statusCode: number;
  error: string;
  message: string;
  userMessage: string;
  reasonCode: PracticeReasonCode;
  retryable: boolean;
  suggestions?: string[];
};

export function practiceBadRequest(args: {
  message: string;
  userMessage: string;
  reasonCode: Extract<PracticeReasonCode, 'UNSUPPORTED_TOPIC' | 'TOPIC_NEEDS_CLARIFICATION' | 'INVALID_REQUEST'>;
  suggestions?: string[];
}): BadRequestException {
  return new BadRequestException({
    statusCode: HttpStatus.BAD_REQUEST,
    error: 'Bad Request',
    message: args.message,
    userMessage: args.userMessage,
    reasonCode: args.reasonCode,
    retryable: false,
    suggestions: args.suggestions ?? [],
  } satisfies PracticeErrorPayload);
}

export function practiceGenerationFailed(args?: {
  message?: string;
  userMessage?: string;
  suggestions?: string[];
}): InternalServerErrorException {
  return new InternalServerErrorException({
    statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
    error: 'Internal Server Error',
    message: args?.message ?? 'Practice generation failed',
    userMessage:
      args?.userMessage ??
      'We could not generate a clean practice set this time. Please try again or make the topic a bit more specific.',
    reasonCode: 'GENERATION_FAILED',
    retryable: true,
    suggestions:
      args?.suggestions ?? [
        'Try a more specific topic',
        'Lower the difficulty',
        'Reduce the number of questions',
      ],
  } satisfies PracticeErrorPayload);
}

export function isPracticeHttpException(error: unknown): error is HttpException {
  if (!(error instanceof HttpException)) return false;
  const res = error.getResponse();
  return !!res && typeof res === 'object' && 'reasonCode' in (res as Record<string, unknown>);
}
