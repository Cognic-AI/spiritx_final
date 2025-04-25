import { EducationMaterialsTable } from "@/components/education/EducationMaterialsTable"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

export default function EducationPage() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Educational Materials</h1>
        <div className="space-x-2">
          <Link href="/dashboard/education/techniques/new">
            <Button variant="outline">Add Technique</Button>
          </Link>
          <Link href="/dashboard/education/science/new">
            <Button>Add Science Article</Button>
          </Link>
        </div>
      </div>

      <Tabs defaultValue="techniques">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="techniques">Techniques</TabsTrigger>
          <TabsTrigger value="science">Science Articles</TabsTrigger>
        </TabsList>
        <TabsContent value="techniques">
          <EducationMaterialsTable type="technique" />
        </TabsContent>
        <TabsContent value="science">
          <EducationMaterialsTable type="science" />
        </TabsContent>
      </Tabs>
    </div>
  )
}
