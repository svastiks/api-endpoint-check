export interface Endpoint {
    id: number;
    url: string;
    name: string;
    active: boolean;
    notification_email: string | null;
    check_interval_seconds: number;
    inserted_at: string;
    updated_at: string;
  }
  
  export interface CheckResult {
    id: number;
    status_code: number;
    response_time_ms: number;
    endpoint_id: number;
    checked_at: string;
  }
  