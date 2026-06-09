export interface SystemInfo {
  machineName: string;
  osName: string;
  osArchitecture: string;
  doNetName: string;
  ip: string;
  cpuCount: number;
  useRam: string;
  startTime: string;
  runTime: string;
  diskInfo: DiskInfo[];
  memoryInfo: MemoryInfo;
}

export interface DiskInfo {
  diskName: string;
  typeName: string;
  totalFree: number;
  totalSize: number;
  used: number;
  availableFreeSpace: number;
  availablePercent: number;
}

export interface MemoryInfo {
  total: number;
  used: number;
  free: number;
  usedRam: string;
  cpuRate: number;
  totalRAM: number;
  ramRate: number;
  freeRam: string;
  appRAMRate: number;
}
