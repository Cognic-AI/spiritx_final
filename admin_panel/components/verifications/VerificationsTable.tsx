"use client"

import { useEffect, useState } from "react"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { db } from "@/lib/firebase/config"
import { collection, getDocs, query, orderBy } from "firebase/firestore"
import Link from "next/link"
import { Search, Eye } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Loader2 } from "lucide-react"

interface Verification {
  id: string
  uid: string
  nicNumber: string
  status: "pending" | "approved" | "rejected"
  createdAt: Date
  updatedAt?: Date
  notes?: string
}

export function VerificationsTable() {
  const [verifications, setVerifications] = useState<Verification[]>([])
  const [filteredVerifications, setFilteredVerifications] = useState<Verification[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")

  useEffect(() => {
    fetchVerifications()
  }, [])

  useEffect(() => {
    filterVerifications()
  }, [searchQuery, statusFilter, verifications])

  async function fetchVerifications() {
    try {
      setIsLoading(true)

      const verificationsSnapshot = await getDocs(query(collection(db, "verifications"), orderBy("createdAt", "desc")))

      const verificationsData = verificationsSnapshot.docs.map((doc) => {
        const data = doc.data()
        return {
          id: doc.id,
          uid: data.uid,
          nicNumber: data.nicNumber,
          status: data.status,
          createdAt: data.createdAt.toDate(),
          updatedAt: data.updatedAt ? data.updatedAt.toDate() : undefined,
          notes: data.notes,
        }
      }) as Verification[]

      setVerifications(verificationsData)
    } catch (error) {
      console.error("Error fetching verifications:", error)
    } finally {
      setIsLoading(false)
    }
  }

  function filterVerifications() {
    let filtered = verifications

    // Apply status filter
    if (statusFilter !== "all") {
      filtered = filtered.filter((v) => v.status === statusFilter)
    }

    // Apply search filter
    if (searchQuery.trim() !== "") {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter(
        (v) => v.nicNumber.toLowerCase().includes(query) || v.uid.toLowerCase().includes(query),
      )
    }

    setFilteredVerifications(filtered)
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
      <div className="flex items-center gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            placeholder="Search by NIC number..."
            className="pl-8"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Filter by status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Statuses</SelectItem>
            <SelectItem value="pending">Pending</SelectItem>
            <SelectItem value="approved">Approved</SelectItem>
            <SelectItem value="rejected">Rejected</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {isLoading ? (
        <div className="flex justify-center py-8">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      ) : filteredVerifications.length === 0 ? (
        <div className="text-center py-8">
          <p className="text-muted-foreground">No verifications found</p>
        </div>
      ) : (
        <div className="border rounded-md">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>NIC Number</TableHead>
                <TableHead>User ID</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Submitted</TableHead>
                <TableHead>Last Updated</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredVerifications.map((verification) => (
                <TableRow key={verification.id}>
                  <TableCell className="font-medium">{verification.nicNumber}</TableCell>
                  <TableCell>{verification.uid}</TableCell>
                  <TableCell>{getStatusBadge(verification.status)}</TableCell>
                  <TableCell>{formatDate(verification.createdAt)}</TableCell>
                  <TableCell>{verification.updatedAt ? formatDate(verification.updatedAt) : "-"}</TableCell>
                  <TableCell className="text-right">
                    <Link href={`/dashboard/verifications/${verification.id}`}>
                      <Button size="sm" variant="ghost">
                        <Eye className="h-4 w-4 mr-2" />
                        View
                      </Button>
                    </Link>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}
    </div>
  )
}
