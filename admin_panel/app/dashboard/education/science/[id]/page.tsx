import { ScienceArticleForm } from "@/components/education/ScienceArticleForm"
import { getScienceArticleById } from "@/lib/firebase/education"

export default async function EditScienceArticlePage({ params }: { params: { id: string } }) {
  const article = await getScienceArticleById(params.id)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Edit Science Article</h1>
      <ScienceArticleForm initialData={article} />
    </div>
  )
}
