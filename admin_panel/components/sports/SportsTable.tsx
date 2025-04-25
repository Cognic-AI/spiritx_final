"use client"

import { useEffect, useState } from "react"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { db } from "@/lib/firebase/config"
import { collection, getDocs, deleteDoc, doc } from "firebase/firestore"
import Link from "next/link"
import { Edit, Trash2, Search } from "lucide-react"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"
import { useToast } from "@/components/ui/use-toast"
import { Loader2 } from "lucide-react"

interface Sport {
  id: string
  name: string
  description: string
  popularity: number
}

export function SportsTable() {
  const [sports, setSports] = useState<Sport[]>([])
  const [filteredSports, setFilteredSports] = useState<Sport[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [sportToDelete, setSportToDelete] = useState<string | null>(null)
  const { toast } = useToast()

  useEffect(() => {
    fetchSports()
  }, [])

  useEffect(() => {
    if (searchQuery.trim() === "") {
      setFilteredSports(sports)
    } else {
      const query = searchQuery.toLowerCase()
      setFilteredSports(
        sports.filter(
          (sport) => sport.name.toLowerCase().includes(query) || sport.description.toLowerCase().includes(query),
        ),
      )
    }
  }, [searchQuery, sports])

  async function fetchSports() {
    try {
      setIsLoading(true)

      const sportsSnapshot = await getDocs(collection(db, "sports"))

      const sportsData = sportsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })) as Sport[]

      setSports(sportsData)
      setFilteredSports(sportsData)
    } catch (error) {
      console.error("Error fetching sports:", error)
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to load sports data",
      })
    } finally {
      setIsLoading(false)
    }
  }

  async function deleteSport(id: string) {
    try {
      await deleteDoc(doc(db, "sports", id))

      setSports(sports.filter((sport) => sport.id !== id))
      toast({
        title: "Sport deleted",
        description: "The sport has been successfully deleted",
      })
    } catch (error) {
      console.error("Error deleting sport:", error)
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to delete sport",
      })
    } finally {
      setSportToDelete(null)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center">
        <div className="relative flex-1">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search sports..."
            className="pl-8"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-8">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      ) : filteredSports.length === 0 ? (
        <div className="text-center py-8">
          <p className="text-muted-foreground">No sports found</p>
        </div>
      ) : (
        <div className="border rounded-md">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Popularity</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredSports.map((sport) => (
                <TableRow key={sport.id}>
                  <TableCell className="font-medium">{sport.name}</TableCell>
                  <TableCell className="max-w-md truncate">{sport.description}</TableCell>
                  <TableCell>{sport.popularity}</TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <Link href={`/dashboard/sports/${sport.id}`}>
                        <Button size="icon" variant="ghost">
                          <Edit className="h-4 w-4" />
                        </Button>
                      </Link>
                      <Button size="icon" variant="ghost" onClick={() => setSportToDelete(sport.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}

      <AlertDialog open={!!sportToDelete} onOpenChange={() => setSportToDelete(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Are you sure?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. This will permanently delete the sport and all associated data.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => sportToDelete && deleteSport(sportToDelete)}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
