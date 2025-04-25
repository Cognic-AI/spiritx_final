import { SportForm } from "@/components/sports/SportForm"
import { getSportById } from "@/lib/firebase/sports"

export default async function EditSportPage({ params }: { params: { id: string } }) {
  const sport = await getSportById(params.id)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Edit Sport</h1>
      <SportForm initialData={sport} />
    </div>
  )
}
