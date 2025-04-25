"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { db } from "@/lib/firebase/config"
import { collection, getDocs, orderBy, query, limit } from "firebase/firestore"
import { Activity, BookOpen, KeyRound, Loader2, Newspaper, Trophy, UserCheck } from "lucide-react"

interface ActivityType {
  id: string
  type: string
  title: string
  timestamp: Date
  user?: string
}

export function RecentActivity() {
  const [activities, setActivities] = useState<ActivityType[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    async function fetchActivities() {
      try {
        setIsLoading(true)

        // Fetch recent activities from the activity log
        const activitiesSnapshot = await getDocs(
          query(collection(db, "activity_log"), orderBy("timestamp", "desc"), limit(10)),
        )

        const activitiesData = activitiesSnapshot.docs.map((doc) => {
          const data = doc.data()
          return {
            id: doc.id,
            type: data.type,
            title: data.title,
            timestamp: data.timestamp.toDate(),
            user: data.user,
          }
        })

        setActivities(activitiesData)
      } catch (error) {
        console.error("Error fetching activities:", error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchActivities()
  }, [])

  function formatDate(date: Date) {
    return new Intl.DateTimeFormat("en-US", {
      day: "numeric",
      month: "short",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date)
  }

  function getActivityIcon(type: string) {
    switch (type) {
      case "sport":
        return <Trophy className="h-4 w-4" />
      case "education":
        return <BookOpen className="h-4 w-4" />
      case "news":
        return <Newspaper className="h-4 w-4" />
      case "verification":
        return <UserCheck className="h-4 w-4" />
      case "password_reset":
        return <KeyRound className="h-4 w-4" />
      default:
        return <Activity className="h-4 w-4" />
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Activity</CardTitle>
      </CardHeader>
      <CardContent>
        {isLoading ? (
          <div className="flex justify-center py-4">
            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
          </div>
        ) : activities.length === 0 ? (
          <p className="text-center text-muted-foreground py-4">No recent activity</p>
        ) : (
          <div className="space-y-4">
            {activities.map((activity) => (
              <div key={activity.id} className="flex items-start gap-4">
                <div className="rounded-full p-2 bg-muted">{getActivityIcon(activity.type)}</div>
                <div className="flex-1 space-y-1">
                  <p className="text-sm font-medium">{activity.title}</p>
                  <div className="flex items-center text-xs text-muted-foreground">
                    <span>{activity.user || "Admin"}</span>
                    <span className="mx-1">•</span>
                    <span>{formatDate(activity.timestamp)}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
