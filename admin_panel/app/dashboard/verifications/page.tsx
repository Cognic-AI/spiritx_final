import { VerificationsTable } from "@/components/verifications/VerificationsTable"

export default function VerificationsPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">NIC Verifications</h1>
      <VerificationsTable />
    </div>
  )
}
