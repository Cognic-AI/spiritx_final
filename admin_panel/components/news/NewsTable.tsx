"use client"

import { useEffect, useState } from "react"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { db } from "@/lib/firebase/config"
import { collection, getDocs, deleteDoc, doc, query, orderBy } from "firebase/firestore"
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

interface NewsArticle {
    id: string
    title: string
    summary: string
    content: string
    category: string
    author: string
    featured: boolean
    publishDate: Date
    updatedAt?: Date
}

export function NewsTable() {
    const [news, setNews] = useState<NewsArticle[]>([])
    const [filteredNews, setFilteredNews] = useState<NewsArticle[]>([])
    const [isLoading, setIsLoading] = useState(true)
    const [searchQuery, setSearchQuery] = useState("")
    const [newsToDelete, setNewsToDelete] = useState<string | null>(null)
    const { toast } = useToast()

    useEffect(() => {
        fetchNews()
    }, [])

    useEffect(() => {
        if (searchQuery.trim() === "") {
            setFilteredNews(news)
        } else {
            const query = searchQuery.toLowerCase()
            setFilteredNews(
                news.filter(
                    (article) =>
                        article.title.toLowerCase().includes(query) ||
                        article.summary.toLowerCase().includes(query) ||
                        article.category.toLowerCase().includes(query),
                ),
            )
        }
    }, [searchQuery, news])

    async function fetchNews() {
        try {
            setIsLoading(true)

            const newsQuery = query(collection(db, "news"), orderBy("publishDate", "desc"))
            const newsSnapshot = await getDocs(newsQuery)

            const newsData = newsSnapshot.docs.map((doc) => {
                const data = doc.data()
                return {
                    id: doc.id,
                    title: data.title || "",
                    summary: data.summary || "",
                    content: data.content || "",
                    category: data.category || "",
                    author: data.author || "",
                    featured: data.featured || false,
                    publishDate: data.publishDate?.toDate() || new Date(),
                    updatedAt: data.updatedAt?.toDate(),
                } as NewsArticle
            })

            setNews(newsData)
            setFilteredNews(newsData)
        } catch (error) {
            console.error("Error fetching news:", error)
            toast({
                variant: "destructive",
                title: "Error",
                description: "Failed to load news data",
            })
        } finally {
            setIsLoading(false)
        }
    }

    async function deleteNews(id: string) {
        try {
            await deleteDoc(doc(db, "news", id))

            setNews(news.filter((article) => article.id !== id))
            toast({
                title: "News deleted",
                description: "The news article has been successfully deleted",
            })
        } catch (error) {
            console.error("Error deleting news:", error)
            toast({
                variant: "destructive",
                title: "Error",
                description: "Failed to delete news article",
            })
        } finally {
            setNewsToDelete(null)
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
                        placeholder="Search news..."
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
            ) : filteredNews.length === 0 ? (
                <div className="text-center py-8">
                    <p className="text-muted-foreground">No news articles found</p>
                </div>
            ) : (
                <div className="border rounded-md">
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead>Title</TableHead>
                                <TableHead>Category</TableHead>
                                <TableHead>Author</TableHead>
                                <TableHead>Published</TableHead>
                                <TableHead>Status</TableHead>
                                <TableHead className="text-right">Actions</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {filteredNews.map((article) => (
                                <TableRow key={article.id}>
                                    <TableCell className="font-medium">{article.title}</TableCell>
                                    <TableCell>{article.category}</TableCell>
                                    <TableCell>{article.author}</TableCell>
                                    <TableCell>{formatDate(article.publishDate)}</TableCell>
                                    <TableCell>
                                        {article.featured ? (
                                            <Badge className="bg-amber-100 text-amber-800 hover:bg-amber-100">Featured</Badge>
                                        ) : (
                                            <Badge variant="outline">Standard</Badge>
                                        )}
                                    </TableCell>
                                    <TableCell className="text-right">
                                        <div className="flex justify-end gap-2">
                                            <Link href={`/dashboard/news/${article.id}`}>
                                                <Button size="icon" variant="ghost">
                                                    <Edit className="h-4 w-4" />
                                                </Button>
                                            </Link>
                                            <Button size="icon" variant="ghost" onClick={() => setNewsToDelete(article.id)}>
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

            <AlertDialog open={!!newsToDelete} onOpenChange={() => setNewsToDelete(null)}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>Are you sure?</AlertDialogTitle>
                        <AlertDialogDescription>
                            This action cannot be undone. This will permanently delete the news article.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Cancel</AlertDialogCancel>
                        <AlertDialogAction
                            onClick={() => newsToDelete && deleteNews(newsToDelete)}
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
