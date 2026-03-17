import { MasteryService } from '../mastery.service';

describe('MasteryService', () => {
  const service = new MasteryService();

  it('creates empty mastery state', () => {
    const s = service.createEmpty('Math', 'Polynomials');
    expect(s.band).toBe('unknown');
    expect(s.attempts).toBe(0);
  });

  it('updates mastery after correct answers', () => {
    let s = service.createEmpty('Math', 'Polynomials');
    s = service.update(s, { isCorrect: true });
    s = service.update(s, { isCorrect: true });
    s = service.update(s, { isCorrect: true });

    expect(s.attempts).toBe(3);
    expect(s.correct).toBe(3);
    expect(s.band === 'solid' || s.band === 'strong').toBe(true);
  });

  it('chooses easier difficulty for weak state', () => {
    let s = service.createEmpty('Math', 'Polynomials');
    s = service.update(s, { isCorrect: false });
    s = service.update(s, { isCorrect: false });
    expect(service.chooseNext(s).targetDifficulty).toBe('easy');
  });

  it('chooses harder difficulty for strong state', () => {
    let s = service.createEmpty('Math', 'Polynomials');
    s = service.update(s, { isCorrect: true });
    s = service.update(s, { isCorrect: true });
    s = service.update(s, { isCorrect: true });
    s = service.update(s, { isCorrect: true });
    expect(service.chooseNext(s).targetDifficulty).toBe('hard');
  });
});
