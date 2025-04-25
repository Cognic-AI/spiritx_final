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
import { Switch } from "@/components/ui/switch"
import { useToast } from "@/components/ui/use-toast"
import { db } from "@/lib/firebase/config"
import { doc, setDoc, updateDoc, collection, serverTimestamp } from "firebase/firestore"
import { CalendarIcon } from "lucide-react"
import { format } from "date-fns"
import { Calendar } from "@/components/ui/calendar"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { cn } from "@/lib/utils"

const formSchema = z.object({
    title: z.string().min(3, { message: "Title must be at least 3 characters" }),
    summary: z.string().min(10, { message: "Summary must be at least 10 characters" }),
    content: z.string().min(50, { message: "Content must be at least 50 characters" }),
    category: z.string().min(1, { message: "Please enter a category" }),
    author: z.string().min(2, { message: "Author name must be at least 2 characters" }),
    featured: z.boolean(),
    publishDate: z.date(),
    imageUrl: z.string().url({ message: "Please enter a valid URL" }).optional().or(z.literal("")),
})

type NewsFormValues = z.infer<typeof formSchema>

interface NewsFormProps {
    initialData?: any
}

export function NewsForm({ initialData }: NewsFormProps) {
    const [isLoading, setIsLoading] = useState(false)
    const router = useRouter()
    const { toast } = useToast()
    const isEditing = !!initialData

    const form = useForm<NewsFormValues>({
        resolver: zodResolver(formSchema),
        defaultValues: initialData
            ? {
                ...initialData,
                publishDate: initialData.publishDate ? new Date(initialData.publishDate) : new Date(),
                imageUrl: initialData.imageUrl || "",
            }
            : {
                title: "",
                summary: "",
                content: "",
                category: "",
                author: "",
                featured: false,
                publishDate: new Date(),
                imageUrl: "",
            },
    })

    async function onSubmit(values: NewsFormValues) {
        try {
            setIsLoading(true)

            const newsData = {
                ...values,
                updatedAt: serverTimestamp(),
            }

            if (isEditing) {
                // Update existing news
                await updateDoc(doc(db, "news", initialData.id), newsData)
                toast({
                    title: "News updated",
                    description: "The news article has been successfully updated",
                })
            } else {
                // Create new news
                const newNewsRef = doc(collection(db, "news"))
                await setDoc(newNewsRef, {
                    ...newsData,
                    id: newNewsRef.id,
                    createdAt: serverTimestamp(),
                })
                toast({
                    title: "News created",
                    description: "The new news article has been successfully created",
                })
            }

            router.push("/dashboard/news")
            router.refresh()
        } catch (error) {
            console.error("Error saving news:", error)
            toast({
                variant: "destructive",
                title: "Error",
                description: "Failed to save news article",
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
                                    <Input placeholder="Sri Lanka Cricket Team Wins Tournament" {...field} />
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
                                    <Input placeholder="Cricket, Tournament" {...field} />
                                </FormControl>
                                <FormDescription>Main category for the news</FormDescription>
                                <FormMessage />
                            </FormItem>
                        )}
                    />
                </div>

                <FormField
                    control={form.control}
                    name="summary"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Summary</FormLabel>
                            <FormControl>
                                <Textarea placeholder="A brief summary of the news article..." className="min-h-20" {...field} />
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
                                <Textarea placeholder="Full content of the news article..." className="min-h-40" {...field} />
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
                        name="publishDate"
                        render={({ field }) => (
                            <FormItem className="flex flex-col">
                                <FormLabel>Publish Date</FormLabel>
                                <Popover>
                                    <PopoverTrigger asChild>
                                        <FormControl>
                                            <Button
                                                variant={"outline"}
                                                className={cn("w-full pl-3 text-left font-normal", !field.value && "text-muted-foreground")}
                                            >
                                                {field.value ? format(field.value, "PPP") : <span>Pick a date</span>}
                                                <CalendarIcon className="ml-auto h-4 w-4 opacity-50" />
                                            </Button>
                                        </FormControl>
                                    </PopoverTrigger>
                                    <PopoverContent className="w-auto p-0" align="start">
                                        <Calendar mode="single" selected={field.value} onSelect={field.onChange} initialFocus />
                                    </PopoverContent>
                                </Popover>
                                <FormMessage />
                            </FormItem>
                        )}
                    />
                </div>

                <FormField
                    control={form.control}
                    name="imageUrl"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Image URL (Optional)</FormLabel>
                            <FormControl>
                                <Input placeholder="https://example.com/image.jpg" {...field} />
                            </FormControl>
                            <FormDescription>URL to the main image for the article</FormDescription>
                            <FormMessage />
                        </FormItem>
                    )}
                />

                <FormField
                    control={form.control}
                    name="featured"
                    render={({ field }) => (
                        <FormItem className="flex flex-row items-center justify-between rounded-lg border p-4">
                            <div className="space-y-0.5">
                                <FormLabel className="text-base">Featured Article</FormLabel>
                                <FormDescription>
                                    Featured articles will be displayed prominently on the app's home screen
                                </FormDescription>
                            </div>
                            <FormControl>
                                <Switch checked={field.value} onCheckedChange={field.onChange} />
                            </FormControl>
                        </FormItem>
                    )}
                />

                <div className="flex gap-4 justify-end">
                    <Button type="button" variant="outline" onClick={() => router.push("/dashboard/news")}>
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
