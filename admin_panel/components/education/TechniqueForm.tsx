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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

const formSchema = z.object({
    title: z.string().min(3, { message: "Title must be at least 3 characters" }),
    description: z.string().min(10, { message: "Description must be at least 10 characters" }),
    content: z.string().min(50, { message: "Content must be at least 50 characters" }),
    category: z.string().min(1, { message: "Please select a category" }),
    author: z.string().min(2, { message: "Author name must be at least 2 characters" }),
    videoUrl: z.string().url({ message: "Please enter a valid URL" }).optional().or(z.literal("")),
    difficultyLevel: z.enum(["beginner", "intermediate", "advanced"]),
})

type TechniqueFormValues = z.infer<typeof formSchema>

interface TechniqueFormProps {
    initialData?: any
}

export function TechniqueForm({ initialData }: TechniqueFormProps) {
    const [isLoading, setIsLoading] = useState(false)
    const router = useRouter()
    const { toast } = useToast()
    const isEditing = !!initialData

    const form = useForm<TechniqueFormValues>({
        resolver: zodResolver(formSchema),
        defaultValues: initialData
            ? {
                ...initialData,
                videoUrl: initialData.videoUrl || "",
            }
            : {
                title: "",
                description: "",
                content: "",
                category: "",
                author: "",
                videoUrl: "",
                difficultyLevel: "intermediate",
            },
    })

    async function onSubmit(values: TechniqueFormValues) {
        try {
            setIsLoading(true)

            const techniqueData = {
                ...values,
                updatedAt: serverTimestamp(),
            }

            if (isEditing) {
                // Update existing technique
                await updateDoc(doc(db, "education", "techniques", "items", initialData.id), techniqueData)
                toast({
                    title: "Technique updated",
                    description: "The technique has been successfully updated",
                })
            } else {
                // Create new technique
                const newTechniqueRef = doc(collection(db, "education", "techniques", "items"))
                await setDoc(newTechniqueRef, {
                    ...techniqueData,
                    id: newTechniqueRef.id,
                    createdAt: serverTimestamp(),
                })
                toast({
                    title: "Technique created",
                    description: "The new technique has been successfully created",
                })
            }

            router.push("/dashboard/education")
            router.refresh()
        } catch (error) {
            console.error("Error saving technique:", error)
            toast({
                variant: "destructive",
                title: "Error",
                description: "Failed to save technique",
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
                                    <Input placeholder="Proper Cricket Batting Stance" {...field} />
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
                                    <Input placeholder="Cricket, Batting" {...field} />
                                </FormControl>
                                <FormDescription>Comma-separated categories</FormDescription>
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
                                <Textarea placeholder="A short description of the technique..." className="min-h-20" {...field} />
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
                                <Textarea placeholder="Detailed explanation of the technique..." className="min-h-40" {...field} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <FormField
                        control={form.control}
                        name="author"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Author</FormLabel>
                                <FormControl>
                                    <Input placeholder="John Doe" {...field} />
                                </FormControl>
                                <FormMessage />
                            </FormItem>
                        )}
                    />

                    <FormField
                        control={form.control}
                        name="difficultyLevel"
                        render={({ field }) => (
                            <FormItem>
                                <FormLabel>Difficulty Level</FormLabel>
                                <Select onValueChange={field.onChange} defaultValue={field.value}>
                                    <FormControl>
                                        <SelectTrigger>
                                            <SelectValue placeholder="Select difficulty level" />
                                        </SelectTrigger>
                                    </FormControl>
                                    <SelectContent>
                                        <SelectItem value="beginner">Beginner</SelectItem>
                                        <SelectItem value="intermediate">Intermediate</SelectItem>
                                        <SelectItem value="advanced">Advanced</SelectItem>
                                    </SelectContent>
                                </Select>
                                <FormMessage />
                            </FormItem>
                        )}
                    />
                </div>

                <FormField
                    control={form.control}
                    name="videoUrl"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Video URL (Optional)</FormLabel>
                            <FormControl>
                                <Input placeholder="https://youtube.com/watch?v=..." {...field} />
                            </FormControl>
                            <FormDescription>YouTube or other video platform URL</FormDescription>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <div className="flex gap-4 justify-end">
                    <Button type="button" variant="outline" onClick={() => router.push("/dashboard/education")}>
                        Cancel
                    </Button>
                    <Button type="submit" disabled={isLoading}>
                        {isLoading ? "Saving..." : isEditing ? "Update Technique" : "Create Technique"}
                    </Button>
                </div>
            </form>
        </Form>
    )
}
