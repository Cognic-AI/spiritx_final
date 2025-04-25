"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { db } from "@/lib/firebase/config"
import { collection, getDocs, query, where } from "firebase/firestore"
import { Trophy, BookOpen, UserCheck, KeyRound } from "lucide-react"

export function DashboardStats() {
  const [stats, setStats] = useState({
    totalSports: 0,
    totalEducationalMaterials: 0,
    pendingVerifications: 0,
    pendingPasswordResets: 0,
  })

  useEffect(() => {
    async function fetchStats() {
      try {
        // Fetch sports count
        const sportsSnapshot = await getDocs(collection(db, "sports"))

        // Fetch educational materials count
        const techniquesSnapshot = await getDocs(collection(db, "education", "techniques", "items"))
        const scienceSnapshot = await getDocs(collection(db, "education", "science", "items"))

        // Fetch pending verifications
        const pendingVerificationsSnapshot = await getDocs(
          query(collection(db, "verifications"), where("status", "==", "pending")),
        )

        // Fetch pending password resets
        const pendingPasswordResetsSnapshot = await getDocs(
          query(collection(db, "password_resets"), where("status", "==", "pending")),
        )

        setStats({
          totalSports: sportsSnapshot.size,
          totalEducationalMaterials: techniquesSnapshot.size + scienceSnapshot.size,
          pendingVerifications: pendingVerificationsSnapshot.size,
          pendingPasswordResets: pendingPasswordResetsSnapshot.size,
        })
      } catch (error) {
        console.error("Error fetching stats:", error)
      }
    }

    fetchStats()
  }, [])

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Total Sports</CardTitle>
          <Trophy className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.totalSports}</div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Educational Materials</CardTitle>
          <BookOpen className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.totalEducationalMaterials}</div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Pending Verifications</CardTitle>
          <UserCheck className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.pendingVerifications}</div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Password Reset Requests</CardTitle>
          <KeyRound className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.pendingPasswordResets}</div>
        </CardContent>
      </Card>
    </div>
  )
}
