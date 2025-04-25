import { DashboardStats } from "@/components/dashboard/DashboardStats"
import { RecentActivity } from "@/components/dashboard/RecentActivity"
import { VerificationRequests } from "@/components/dashboard/VerificationRequests"

export default function Dashboard() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Dashboard</h1>

      <DashboardStats />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <VerificationRequests />
        <RecentActivity />
      </div>
    </div>
  )
}
