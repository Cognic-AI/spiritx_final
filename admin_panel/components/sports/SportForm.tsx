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
import { Slider } from "@/components/ui/slider"
import { useToast } from "@/components/ui/use-toast"
import { db } from "@/lib/firebase/config"
import { doc, setDoc, updateDoc, collection } from "firebase/firestore"

const formSchema = z.object({
  name: z.string().min(2, { message: "Name must be at least 2 characters" }),
  description: z.string().min(10, { message: "Description must be at least 10 characters" }),
  popularity: z.number().min(0).max(10),
  skillsRequired: z.string(),
  physicalAttributes: z.string(),
  famousAthletes: z.string(),
  equipmentNeeded: z.string(),
  trainingFacilities: z.string(),
  icon: z.string().optional(),
})

type SportFormValues = z.infer<typeof formSchema>

interface SportFormProps {
  initialData?: any
}

export function SportForm({ initialData }: SportFormProps) {
  const [isLoading, setIsLoading] = useState(false)
  const router = useRouter()
  const { toast } = useToast()
  const isEditing = !!initialData

  const form = useForm<SportFormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: initialData
      ? {
        ...initialData,
        skillsRequired: initialData.skillsRequired?.join(", ") || "",
        physicalAttributes: initialData.physicalAttributes?.join(", ") || "",
        famousAthletes: initialData.famousAthletes?.join(", ") || "",
        equipmentNeeded: initialData.equipmentNeeded?.join(", ") || "",
        trainingFacilities: initialData.trainingFacilities?.join(", ") || "",
      }
      : {
        name: "",
        description: "",
        popularity: 5,
        skillsRequired: "",
        physicalAttributes: "",
        famousAthletes: "",
        equipmentNeeded: "",
        trainingFacilities: "",
        icon: "sports",
      },
  })

  async function onSubmit(values: SportFormValues) {
    try {
      setIsLoading(true)

      // Convert comma-separated strings to arrays
      const sportData = {
        ...values,
        skillsRequired: values.skillsRequired
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
        physicalAttributes: values.physicalAttributes
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
        famousAthletes: values.famousAthletes
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
        equipmentNeeded: values.equipmentNeeded
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
        trainingFacilities: values.trainingFacilities
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean),
        icon: values.icon || "sports",
      }

      if (isEditing) {
        // Update existing sport
        await updateDoc(doc(db, "sports", initialData.id), sportData)
        toast({
          title: "Sport updated",
          description: "The sport has been successfully updated",
        })
      } else {
        // Create new sport
        const newSportRef = doc(collection(db, "sports"))
        await setDoc(newSportRef, {
          id: newSportRef.id,
          ...sportData,
        })
        toast({
          title: "Sport created",
          description: "The new sport has been successfully created",
        })
      }

      router.push("/dashboard/sports")
      router.refresh()
    } catch (error) {
      console.error("Error saving sport:", error)
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to save sport",
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
            name="name"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Name</FormLabel>
                <FormControl>
                  <Input placeholder="Cricket" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="icon"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Icon</FormLabel>
                <FormControl>
                  <Input placeholder="sports" {...field} />
                </FormControl>
                <FormDescription>Icon name for the sport (e.g., cricket, football, swimming)</FormDescription>
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
                <Textarea placeholder="A detailed description of the sport..." className="min-h-32" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="popularity"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Popularity (0-10)</FormLabel>
              <div className="flex items-center gap-4">
                <FormControl>
                  <Slider
                    min={0}
                    max={10}
                    step={0.1}
                    value={[field.value]}
                    onValueChange={(value) => field.onChange(value[0])}
                  />
                </FormControl>
                <span className="w-12 text-center">{field.value ? field.value.toFixed(1) : "Und"}</span>
              </div>
              <FormMessage />
            </FormItem>
          )}
        />

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <FormField
            control={form.control}
            name="skillsRequired"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Skills Required</FormLabel>
                <FormControl>
                  <Input placeholder="Hand-eye coordination, Endurance, Strategy" {...field} />
                </FormControl>
                <FormDescription>Comma-separated list of skills</FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="physicalAttributes"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Physical Attributes</FormLabel>
                <FormControl>
                  <Input placeholder="Agility, Strength, Reflexes" {...field} />
                </FormControl>
                <FormDescription>Comma-separated list of attributes</FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <FormField
            control={form.control}
            name="famousAthletes"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Famous Athletes</FormLabel>
                <FormControl>
                  <Input placeholder="Kumar Sangakkara, Mahela Jayawardene" {...field} />
                </FormControl>
                <FormDescription>Comma-separated list of athletes</FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="equipmentNeeded"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Equipment Needed</FormLabel>
                <FormControl>
                  <Input placeholder="Bat, Ball, Pads, Gloves" {...field} />
                </FormControl>
                <FormDescription>Comma-separated list of equipment</FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />
        </div>

        <FormField
          control={form.control}
          name="trainingFacilities"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Training Facilities</FormLabel>
              <FormControl>
                <Input placeholder="Cricket grounds, Indoor nets, Fitness centers" {...field} />
              </FormControl>
              <FormDescription>Comma-separated list of facilities</FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <div className="flex gap-4 justify-end">
          <Button type="button" variant="outline" onClick={() => router.push("/dashboard/sports")}>
            Cancel
          </Button>
          <Button type="submit" disabled={isLoading}>
            {isLoading ? "Saving..." : isEditing ? "Update Sport" : "Create Sport"}
          </Button>
        </div>
      </form>
    </Form>
  )
}
