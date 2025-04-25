"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { db } from "@/lib/firebase/config"
import { collection, getDocs, query, where, orderBy, limit } from "firebase/firestore"
import Link from "next/link"
import { Loader2 } from "lucide-react"

interface Verification {
  id: string
  uid: string
  nicNumber: string
  status: "pending" | "approved" | "rejected"
  createdAt: Date
}

export function VerificationRequests() {
  const [verifications, setVerifications] = useState<Verification[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    async function fetchVerifications() {
      try {
        setIsLoading(true)

        // Fetch pending verifications
        const verificationsSnapshot = await getDocs(
          query(
            collection(db, "verifications"),
            where("status", "==", "pending"),
            orderBy("createdAt", "desc"),
            limit(5),
          ),
        )

        const verificationsData = verificationsSnapshot.docs.map((doc) => {
          const data = doc.data()
          return {
            id: doc.id,
            uid: data.uid,
            nicNumber: data.nicNumber,
            status: data.status,
            createdAt: data.createdAt.toDate(),
          }
        })

        setVerifications(verificationsData)
      } catch (error) {
        console.error("Error fetching verifications:", error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchVerifications()
  }, [])

  function formatDate(date: Date) {
    return new Intl.DateTimeFormat("en-US", {
      day: "numeric",
      month: "short",
      year: "numeric",
    }).format(date)
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Pending Verifications</CardTitle>
        <Link href="/dashboard/verifications">
          <Button variant="ghost" size="sm">
            View All
          </Button>
        </Link>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <div className="flex justify-center py-4">
            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
          </div>
        ) : verifications.length === 0 ? (
          <p className="text-center text-muted-foreground py-4">No pending verifications</p>
        ) : (
          <div className="space-y-4">
            {verifications.map((verification) => (
              <div key={verification.id} className="flex items-center justify-between">
                <div>
                  <p className="font-medium">NIC: {verification.nicNumber}</p>
                  <p className="text-sm text-muted-foreground">Submitted on {formatDate(verification.createdAt)}</p>
                </div>
                <Link href={`/dashboard/verifications/${verification.id}`}>
                  <Button size="sm">Review</Button>
                </Link>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
