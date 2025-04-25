import { NewsForm } from "@/components/news/NewsForm"
import { getNewsById } from "@/lib/firebase/news"

export default async function EditNewsPage({ params }: { params: { id: string } }) {
  const news = await getNewsById(params.id)

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Edit News Article</h1>
      <NewsForm initialData={news} />
    </div>
  )
}
