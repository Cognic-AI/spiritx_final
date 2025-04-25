import { TechniqueForm } from "@/components/education/TechniqueForm"
import { getTechniqueById } from "@/lib/firebase/education"

export default async function EditTechniquePage({ params }: { params: { id: string } }) {
  const technique = await getTechniqueById(params.id)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Edit Technique</h1>
      <TechniqueForm initialData={technique} />
    </div>
  )
}
