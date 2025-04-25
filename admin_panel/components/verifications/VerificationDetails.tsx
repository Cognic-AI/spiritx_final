"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import { useToast } from "@/components/ui/use-toast"
import Image from "next/image"

interface VerificationDetailsProps {
  verification: any
}

export function VerificationDetails({ verification }: VerificationDetailsProps) {
  const [status, setStatus] = useState(verification.status)
  const [notes, setNotes] = useState(verification.notes || "")
  const [isLoading, setIsLoading] = useState(false)
  const router = useRouter()
  const { toast } = useToast()

  async function updateVerification(newStatus: string) {
    try {
      setIsLoading(true)

      const response = await fetch(`/api/verifications/${verification.id}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          status: newStatus,
          notes,
        }),
      })

      if (!response.ok) {
        throw new Error("Failed to update verification")
      }

      setStatus(newStatus)

      toast({
        title: "Verification updated",
        description: `The verification has been ${newStatus}`,
      })

      router.refresh()
    } catch (error) {
      console.error("Error updating verification:", error)
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to update verification",
      })
    } finally {
      setIsLoading(false)
    }
  }

  function formatDate(date: Date) {
    return new Intl.DateTimeFormat("en-US", {
      day: "numeric",
      month: "long",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date)
  }

  function getStatusBadge(status: string) {
    switch (status) {
      case "pending":
        return <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100">Pending</Badge>
      case "approved":
        return <Badge className="bg-green-100 text-green-800 hover:bg-green-100">Approved</Badge>
      case "rejected":
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-100">Rejected</Badge>
      default:
        return <Badge>Unknown</Badge>
    }
  }

  // Function to render base64 image
  function renderNicImage() {
    if (!verification.nicImageUrl) return null

    if (verification.nicImageUrl.startsWith("data:image")) {
      return (
        <div className="mt-4">
          <p className="text-sm font-medium mb-2">NIC Image:</p>
          <div className="border rounded-md overflow-hidden">
            <img
              src={verification.nicImageUrl || "/placeholder.svg"}
              alt="NIC"
              className="w-full max-h-96 object-contain"
            />
          </div>
        </div>
      )
    }

    return (
      <div className="mt-4">
        <p className="text-sm font-medium mb-2">NIC Image:</p>
        <div className="border rounded-md overflow-hidden">
          <Image
            src={verification.nicImageUrl || "/placeholder.svg"}
            alt="NIC"
            width={400}
            height={300}
            className="w-full max-h-96 object-contain"
          />
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <h2 className="text-xl font-semibold">Verification Details</h2>
          {getStatusBadge(status)}
        </div>
        <Button variant="outline" onClick={() => router.push("/dashboard/verifications")}>
          Back to List
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardContent className="pt-6">
            <dl className="space-y-4">
              <div>
                <dt className="text-sm font-medium text-gray-500">NIC Number</dt>
                <dd className="mt-1 text-lg font-semibold">{verification.nicNumber}</dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-gray-500">User ID</dt>
                <dd className="mt-1">{verification.uid}</dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-gray-500">Submitted On</dt>
                <dd className="mt-1">{formatDate(verification.createdAt)}</dd>
              </div>
              {verification.updatedAt && (
                <div>
                  <dt className="text-sm font-medium text-gray-500">Last Updated</dt>
                  <dd className="mt-1">{formatDate(verification.updatedAt)}</dd>
                </div>
              )}
            </dl>

            {renderNicImage()}
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6 space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-500">Admin Notes</label>
              <Textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Add notes about this verification..."
                className="mt-1 h-32"
                disabled={status !== "pending" || isLoading}
              />
            </div>

            {status === "pending" && (
              <div className="flex gap-4 pt-4">
                <Button
                  onClick={() => updateVerification("approved")}
                  className="flex-1 bg-green-600 hover:bg-green-700"
                  disabled={isLoading}
                >
                  Approve
                </Button>
                <Button
                  onClick={() => updateVerification("rejected")}
                  className="flex-1 bg-red-600 hover:bg-red-700"
                  disabled={isLoading}
                >
                  Reject
                </Button>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
