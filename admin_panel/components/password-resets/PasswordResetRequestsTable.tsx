"use client"

import { useEffect, useState } from "react"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { db } from "@/lib/firebase/config"
import { collection, getDocs, query, orderBy, doc, updateDoc } from "firebase/firestore"
import { Search } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import { useToast } from "@/components/ui/use-toast"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { auth } from "@/lib/firebase/config"
import { sendPasswordResetEmail } from "firebase/auth"
import { Loader2 } from "lucide-react"

interface PasswordReset {
  id: string
  uid: string
  email: string
  reason: string
  status: "pending" | "approved" | "rejected"
  createdAt: Date
  updatedAt?: Date
  notes?: string
}

export function PasswordResetRequestsTable() {
  const [resets, setResets] = useState<PasswordReset[]>([])
  const [filteredResets, setFilteredResets] = useState<PasswordReset[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedReset, setSelectedReset] = useState<PasswordReset | null>(null)
  const [notes, setNotes] = useState("")
  const [isProcessing, setIsProcessing] = useState(false)
  const { toast } = useToast()

  useEffect(() => {
    fetchPasswordResets()
  }, [])

  useEffect(() => {
    if (searchQuery.trim() === "") {
      setFilteredResets(resets)
    } else {
      const query = searchQuery.toLowerCase()
      setFilteredResets(
        resets.filter(
          (reset) => reset.email.toLowerCase().includes(query) || reset.reason.toLowerCase().includes(query),
        ),
      )
    }
  }, [searchQuery, resets])

  async function fetchPasswordResets() {
    try {
      setIsLoading(true)

      const resetsSnapshot = await getDocs(query(collection(db, "password_resets"), orderBy("createdAt", "desc")))

      const resetsData = resetsSnapshot.docs.map((doc) => {
        const data = doc.data()
        return {
          id: doc.id,
          uid: data.uid,
          email: data.email,
          reason: data.reason,
          status: data.status,
          createdAt: data.createdAt.toDate(),
          updatedAt: data.updatedAt ? data.updatedAt.toDate() : undefined,
          notes: data.notes,
        }
      }) as PasswordReset[]

      setResets(resetsData)
      setFilteredResets(resetsData)
    } catch (error) {
      console.error("Error fetching password resets:", error)
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to load password reset requests",
      })
    } finally {
      setIsLoading(false)
    }
  }

  async function handleResetAction(action: "approved" | "rejected") {
    if (!selectedReset) return

    try {
      setIsProcessing(true)

      // Update in Firestore
      await updateDoc(doc(db, "password_resets", selectedReset.id), {
        status: action,
        notes,
        updatedAt: new Date(),
      })

      // If approved, send password reset email
      if (action === "approved") {
        await sendPasswordResetEmail(auth, selectedReset.email)
      }

      // Update local state
      setResets(
        resets.map((reset) =>
          reset.id === selectedReset.id ? { ...reset, status: action, notes, updatedAt: new Date() } : reset,
        ),
      )

      toast({
        title: "Request processed",
        description: `The password reset request has been ${action}`,
      })

      // Close dialog
      setSelectedReset(null)
      setNotes("")
    } catch (error) {
      console.error("Error processing password reset:", error)
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to process password reset request",
      })
    } finally {
      setIsProcessing(false)
    }
  }

  function formatDate(date: Date) {
    return new Intl.DateTimeFormat("en-US", {
      day: "numeric",
      month: "short",
      year: "numeric",
    }).format(date)
  }

  function getStatusBadge(status: string) {
    switch (status) {
      case "pending":
        return (
          <Badge variant="outline" className="bg-yellow-50 text-yellow-700 border-yellow-200">
            Pending
          </Badge>
        )
      case "approved":
        return (
          <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
            Approved
          </Badge>
        )
      case "rejected":
        return (
          <Badge variant="outline" className="bg-red-50 text-red-700 border-red-200">
            Rejected
          </Badge>
        )
      default:
        return <Badge variant="outline">Unknown</Badge>
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center">
        <div className="relative flex-1">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search by email..."
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
      ) : filteredResets.length === 0 ? (
        <div className="text-center py-8">
          <p className="text-muted-foreground">No password reset requests found</p>
        </div>
      ) : (
        <div className="border rounded-md">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Email</TableHead>
                <TableHead>Reason</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Requested</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredResets.map((reset) => (
                <TableRow key={reset.id}>
                  <TableCell className="font-medium">{reset.email}</TableCell>
                  <TableCell className="max-w-xs truncate">{reset.reason}</TableCell>
                  <TableCell>{getStatusBadge(reset.status)}</TableCell>
                  <TableCell>{formatDate(reset.createdAt)}</TableCell>
                  <TableCell className="text-right">
                    {reset.status === "pending" ? (
                      <Button
                        size="sm"
                        onClick={() => {
                          setSelectedReset(reset)
                          setNotes(reset.notes || "")
                        }}
                      >
                        Process
                      </Button>
                    ) : (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => {
                          setSelectedReset(reset)
                          setNotes(reset.notes || "")
                        }}
                      >
                        View
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}

      <Dialog open={!!selectedReset} onOpenChange={(open) => !open && setSelectedReset(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>
              {selectedReset?.status === "pending"
                ? "Process Password Reset Request"
                : "Password Reset Request Details"}
            </DialogTitle>
            <DialogDescription>
              {selectedReset?.status === "pending"
                ? "Review and process this password reset request."
                : `This request has been ${selectedReset?.status}.`}
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="space-y-1">
              <p className="text-sm font-medium">Email</p>
              <p className="text-sm">{selectedReset?.email}</p>
            </div>

            <div className="space-y-1">
              <p className="text-sm font-medium">Reason</p>
              <p className="text-sm">{selectedReset?.reason}</p>
            </div>

            <div className="space-y-1">
              <p className="text-sm font-medium">Requested On</p>
              <p className="text-sm">{selectedReset?.createdAt && formatDate(selectedReset.createdAt)}</p>
            </div>

            <div className="space-y-1">
              <label className="text-sm font-medium">Admin Notes</label>
              <Textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Add notes about this request..."
                disabled={selectedReset?.status !== "pending" || isProcessing}
              />
            </div>
          </div>

          <DialogFooter>
            {selectedReset?.status === "pending" ? (
              <div className="flex gap-2 w-full">
                <Button
                  variant="outline"
                  onClick={() => setSelectedReset(null)}
                  disabled={isProcessing}
                  className="flex-1"
                >
                  Cancel
                </Button>
                <Button
                  variant="destructive"
                  onClick={() => handleResetAction("rejected")}
                  disabled={isProcessing}
                  className="flex-1"
                >
                  Reject
                </Button>
                <Button onClick={() => handleResetAction("approved")} disabled={isProcessing} className="flex-1">
                  Approve & Send Email
                </Button>
              </div>
            ) : (
              <Button onClick={() => setSelectedReset(null)}>Close</Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
