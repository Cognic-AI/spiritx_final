"use client"

import { useEffect, useState } from "react"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { db } from "@/lib/firebase/config"
import { collection, getDocs, deleteDoc, doc, query, where } from "firebase/firestore"
import Link from "next/link"
import { Edit, Trash2, Search, Loader2 } from "lucide-react"
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
import { Badge } from "@/components/ui/badge"

interface EducationMaterial {
    id: string
    title: string
    description: string
    content: string
    type: string
    sport?: string
    level?: string
    category?: string
    author: string
    tags?: string[]
    createdAt: Date
    updatedAt?: Date
    publishDate?: Date
}

interface EducationMaterialsTableProps {
    type: "technique" | "science"
}

export function EducationMaterialsTable({ type }: EducationMaterialsTableProps) {
    const [materials, setMaterials] = useState<EducationMaterial[]>([])
    const [filteredMaterials, setFilteredMaterials] = useState<EducationMaterial[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [searchQuery, setSearchQuery] = useState("")
    const [materialToDelete, setMaterialToDelete] = useState<string | null>(null)
    const { toast } = useToast()

    useEffect(() => {
        fetchMaterials()
    }, [type])

    useEffect(() => {
        if (searchQuery.trim() === "") {
            setFilteredMaterials(materials)
        } else {
            const query = searchQuery.toLowerCase()
            setFilteredMaterials(
                materials.filter(
                    (material) =>
                        material.title.toLowerCase().includes(query) ||
                        material.description.toLowerCase().includes(query) ||
                        material.sport?.toLowerCase().includes(query) ||
                        material.category?.toLowerCase().includes(query),
                ),
            )
        }
    }, [searchQuery, materials])

    async function fetchMaterials() {
        try {
            setIsLoading(true)

            const materialsRef = query(collection(db, "education"), where("type", "==", type))
            const materialsSnapshot = await getDocs(materialsRef)

            const materialsData = materialsSnapshot.docs.map((doc) => {
                const data = doc.data()
                return {
                    id: doc.id,
                    title: data.title || "",
                    description: data.description || "",
                    content: data.content || "",
                    type: type === "technique" ? "technique" : "science",
                    sport: data.sport || "",
                    level: data.level || "",
                    category: data.category || "",
                    author: data.author || "",
                    tags: data.tags || [],
                    createdAt: data.createdAt?.toDate() || new Date(),
                    updatedAt: data.updatedAt?.toDate(),
                } as EducationMaterial
            })

            setMaterials(materialsData)
            setFilteredMaterials(materialsData)
        } catch (error) {
            console.error(`Error fetching ${type}:`, error)
            toast({
                variant: "destructive",
                title: "Error",
                description: `Failed to load ${type} data`,
            })
        } finally {
            setIsLoading(false)
        }
    }

    async function deleteMaterial(id: string) {
        try {
            await deleteDoc(doc(db, "education", id))

            setMaterials(materials.filter((material) => material.id !== id))
            toast({
                title: "Material deleted",
                description: "The educational material has been successfully deleted",
            })
        } catch (error) {
            console.error("Error deleting material:", error)
            toast({
                variant: "destructive",
                title: "Error",
                description: "Failed to delete educational material",
            })
        } finally {
            setMaterialToDelete(null)
        }
    }

    function formatDate(date: Date) {
        return new Intl.DateTimeFormat("en-US", {
            day: "numeric",
            month: "short",
            year: "numeric",
        }).format(date)
    }

    return (
        <div className="space-y-4">
            <div className="flex items-center">
                <div className="relative flex-1">
                    <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                        placeholder={`Search ${type}...`}
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
            ) : filteredMaterials.length === 0 ? (
                <div className="text-center py-8">
                    <p className="text-muted-foreground">No educational materials found</p>
                </div>
            ) : (
                <div className="border rounded-md">
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Title</TableHead>
                                <TableHead>{type === "technique" ? "Sport" : "Category"}</TableHead>
                                {type === "technique" && <TableHead>Level</TableHead>}
                                <TableHead>Author</TableHead>
                                <TableHead>Published</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {filteredMaterials.map((material) => (
                                <TableRow key={material.id}>
                                    <TableCell className="font-medium">{material.title}</TableCell>
                                    <TableCell>{type === "technique" ? material.sport : material.category}</TableCell>
                                    {type === "technique" && (
                                        <TableCell>
                                            <Badge
                                                variant="outline"
                                                className={
                                                    material.level === "beginner"
                                                        ? "bg-green-100 text-green-800"
                                                        : material.level === "intermediate"
                                                            ? "bg-blue-100 text-blue-800"
                                                            : "bg-red-100 text-red-800"
                                                }
                                            >
                                                {material.level && material.level.toString().charAt(0).toUpperCase() + material.level?.slice(1) || "N/A"}
                                            </Badge>
                                        </TableCell>
                                    )}
                                    <TableCell>{material.author}</TableCell>
                                    <TableCell>{material.publishDate ? formatDate(material.publishDate) : "Draft"}</TableCell>
                                    <TableCell className="text-right">
                                        <div className="flex justify-end gap-2">
                                            <Link href={`/dashboard/education/${type}/${material.id}`}>
                                                <Button size="icon" variant="ghost">
                                                    <Edit className="h-4 w-4" />
                                                </Button>
                                            </Link>
                                            <Button size="icon" variant="ghost" onClick={() => setMaterialToDelete(material.id)}>
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

            <AlertDialog open={!!materialToDelete} onOpenChange={() => setMaterialToDelete(null)}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>Are you sure?</AlertDialogTitle>
                        <AlertDialogDescription>
                            This action cannot be undone. This will permanently delete the educational material.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Cancel</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={() => materialToDelete && deleteMaterial(materialToDelete)}
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
