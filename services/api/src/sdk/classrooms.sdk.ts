export class ClassroomsSdk {
  constructor(private readonly http?: any) {}

  // minimal stubs so smoke compiles
  async listStudent(): Promise<any[]> {
    return [];
  }

  async getStudent(id: string): Promise<any> {
    return { id };
  }
}
