export class ContractEscrow {
  state: any;
  env: any;

  constructor(state: any, env: any) {
    this.state = state;
    this.env = env;
  }

  async fetch(_request: Request) {
    return new Response('Escrow DO stub', { status: 200 });
  }
}

