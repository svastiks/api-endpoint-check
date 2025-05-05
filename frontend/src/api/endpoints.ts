import { CheckResult } from "../types/endpoint";
import api from "./axios";

// Fetch the latest check result for a given endpoint
export async function fetchLatestCheckResult(endpointId: number): Promise<CheckResult | null> {
  try {
    const response = await api.get<{ data: CheckResult[] }>(`/check_results/${endpointId}?limit=1`);
    return response.data.data[0] || null;
  } catch {
    return null;
  }
}
