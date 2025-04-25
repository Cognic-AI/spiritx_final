import { NewsForm } from "@/components/news/NewsForm"

export default function NewNewsPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Add News Article</h1>
      <NewsForm />
    </div>
  )
}
