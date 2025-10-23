/**
 * Entidad de dominio que representa la información del túnel SSH
 */
export class SshInfo {
  constructor(
    public readonly command: string,
    public readonly host: string,
    public readonly port: number,
    public readonly user: string,
    public readonly timestamp: Date,
    public readonly isActive: boolean
  ) {}

  static fromCommand(command: string): SshInfo {
    // Parsear comando: ssh hecmerod@bore.pub -p 12345
    const userHostMatch = command.match(/ssh\s+(\w+)@([\w.]+)/);
    const portMatch = command.match(/-p\s+(\d+)/);

    if (!userHostMatch || !portMatch) {
      throw new Error('Invalid SSH command format');
    }

    return new SshInfo(
      command,
      userHostMatch[2], // host
      parseInt(portMatch[1], 10), // port
      userHostMatch[1], // user
      new Date(),
      true
    );
  }

  toJSON() {
    return {
      command: this.command,
      host: this.host,
      port: this.port,
      user: this.user,
      timestamp: this.timestamp.toISOString(),
      isActive: this.isActive,
    };
  }
}
