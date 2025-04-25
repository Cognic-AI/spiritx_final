"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import { Button } from "@/components/ui/button"
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { useToast } from "@/components/ui/use-toast"
import { db } from "@/lib/firebase/config"
import { doc, setDoc, updateDoc, collection, serverTimestamp } from "firebase/firestore"

const formSchema = z.object({
    title: z.string().min(3, { message: "Title must be at least 3 characters" }),
    description: z.string().min(10, { message: "Description must be at least 10 characters" }),
    content: z.string().min(100, { message: "Content must be at least 100 characters" }),
    category: z.string().min(1, { message: "Please enter a category" }),
    author: z.string().min(2, { message: "Author name must be at least 2 characters" }),
    references: z.string(),
    tags: z.string(),
})

type ScienceArticleFormValues = z.infer<typeof formSchema>

interface ScienceArticleFormProps {
    initialData?: any
}

export function ScienceArticleForm({ initialData }: ScienceArticleFormProps) {
    const [isLoading, setIsLoading] = useState(false)
    const router = useRouter()
    const { toast } = useToast()
    const isEditing = !!initialData

    const form = useForm<ScienceArticleFormValues>({
        resolver: zodResolver(formSchema),
        defaultValues: initialData
            ? {
                ...initialData,
                references: initialData.references?.join("\n") || "",
                tags: initialData.tags?.join(", ") || "",
            }
            : {
                title: "",
                description: "",
                content: "",
                category: "",
                author: "",
                references: "",
                tags: "",
            },
    })

    async function onSubmit(values: ScienceArticleFormValues) {
        try {
            setIsLoading(true)

            // Process references and tags
            const references = values.references
                .split("\n")
                .map((ref) => ref.trim())
                .filter(Boolean)

            const tags = values.tags
                .split(",")
                .map((tag) => tag.trim())
                .filter(Boolean)

            const articleData = {
                ...values,
                references,
                tags,
                updatedAt: serverTimestamp(),
            }

            if (isEditing) {
                // Update existing article
                await updateDoc(doc(db, "educational_content", "science", "items", initialData.id), articleData)
                toast({
                    title: "Article updated",
                    description: "The science article has been successfully updated",
                })
            } else {
                // Create new article
                const newArticleRef = doc(collection(db, "educational_content", "science", "items"))
                await setDoc(newArticleRef, {
                    ...articleData,
                    id: newArticleRef.id,
                    createdAt: serverTimestamp(),
                })
                toast({
                    title: "Article created",
                    description: "The new science article has been successfully created",
                })
            }

            router.push("/dashboard/education")
            router.refresh()
        } catch (error) {
            console.error("Error saving science article:", error)
            toast({
                variant: "destructive",
                title: "Error",
                description: "Failed to save science article",
            })
        } finally {
            setIsLoading(false)
        }
    }

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <FormField
                        control={form.control}
                        name="title"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Title</FormLabel>
                                <FormControl>
                                    <Input placeholder="The Science of Sports Nutrition" {...field} />
                                </FormControl>
                                <FormMessage />
                            </FormItem>
                        )}
                    />

                    <FormField
                        control={form.control}
                        name="category"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Category</FormLabel>
                                <FormControl>
                                    <Input placeholder="Nutrition, Health" {...field} />
                                </FormControl>
                                <FormDescription>Main category for the article</FormDescription>
                                <FormMessage />
                            </FormItem>
                        )}
                    />
                </div>

                <FormField
                    control={form.control}
                    name="description"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Description</FormLabel>
                            <FormControl>
                                <Textarea placeholder="A short description of the article..." className="min-h-20" {...field} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <FormField
                    control={form.control}
                    name="content"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Content</FormLabel>
                            <FormControl>
                                <Textarea placeholder="Full content of the article..." className="min-h-60" {...field} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <FormField
                    control={form.control}
                    name="author"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Author</FormLabel>
                            <FormControl>
                                <Input placeholder="Dr. Jane Smith" {...field} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <FormField
                    control={form.control}
                    name="references"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>References</FormLabel>
                            <FormControl>
                                <Textarea placeholder="One reference per line..." className="min-h-20" {...field} />
                            </FormControl>
                            <FormDescription>Enter each reference on a new line</FormDescription>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <FormField
                    control={form.control}
                    name="tags"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Tags</FormLabel>
                            <FormControl>
                                <Input placeholder="nutrition, protein, recovery" {...field} />
                            </FormControl>
                            <FormDescription>Comma-separated tags</FormDescription>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <div className="flex gap-4 justify-end">
                    <Button type="button" variant="outline" onClick={() => router.push("/dashboard/education")}>
                        Cancel
                    </Button>
                    <Button type="submit" disabled={isLoading}>
                        {isLoading ? "Saving..." : isEditing ? "Update Article" : "Create Article"}
                    </Button>
                </div>
            </form>
        </Form>
    )
}
