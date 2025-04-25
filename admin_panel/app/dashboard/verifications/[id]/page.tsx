import { VerificationDetails } from "@/components/verifications/VerificationDetails"
import { getVerificationById } from "@/lib/firebase/verifications"

export default async function VerificationDetailsPage({ params }: { params: { id: string } }) {
  const verification = await getVerificationById(params.id)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Verification Details</h1>
      <VerificationDetails verification={verification} />
    </div>
  )
}
