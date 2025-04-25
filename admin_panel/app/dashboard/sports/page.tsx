import { SportsTable } from "@/components/sports/SportsTable"
import { Button } from "@/components/ui/button"
import Link from "next/link"

export default function SportsPage() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Sports Management</h1>
        <Link href="/dashboard/sports/new">
          <Button>Add New Sport</Button>
        </Link>
      </div>

      <SportsTable />
    </div>
  )
}
