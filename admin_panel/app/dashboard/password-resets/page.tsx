import { PasswordResetRequestsTable } from "@/components/password-resets/PasswordResetRequestsTable"

export default function PasswordResetsPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Password Reset Requests</h1>
      <PasswordResetRequestsTable />
    </div>
  )
}
