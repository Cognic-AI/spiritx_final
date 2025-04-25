import { SportForm } from "@/components/sports/SportForm"

export default function NewSportPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Add New Sport</h1>
      <SportForm />
    </div>
  )
}
