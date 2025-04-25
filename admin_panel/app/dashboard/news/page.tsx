import { NewsTable } from "@/components/news/NewsTable"
import { Button } from "@/components/ui/button"
import Link from "next/link"

export default function NewsPage() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">News Management</h1>
        <Link href="/dashboard/news/new">
          <Button>Add News Article</Button>
        </Link>
      </div>

      <NewsTable />
    </div>
  )
}
