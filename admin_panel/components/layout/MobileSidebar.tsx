"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import { LayoutDashboard, Trophy, BookOpen, Newspaper, UserCheck, KeyRound, LogOut } from "lucide-react"
import { useAuth } from "@/context/AuthContext"

const navItems = [
  { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { name: "Sports", href: "/dashboard/sports", icon: Trophy },
  { name: "Education", href: "/dashboard/education", icon: BookOpen },
  { name: "News", href: "/dashboard/news", icon: Newspaper },
  { name: "Verifications", href: "/dashboard/verifications", icon: UserCheck },
  { name: "Password Resets", href: "/dashboard/password-resets", icon: KeyRound },
]

interface MobileSidebarProps {
  onClose: () => void
}

export default function MobileSidebar({ onClose }: MobileSidebarProps) {
  const pathname = usePathname()
  const { logout } = useAuth()

  return (
    <div className="fixed inset-0 z-50 bg-white md:hidden">
      <div className="flex flex-col h-full">
        <div className="flex items-center justify-center h-16 border-b">
          <h1 className="text-xl font-bold text-primary">SL Sports Admin</h1>
        </div>

        <nav className="flex-1 px-2 py-4 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const isActive = pathname === item.href || pathname.startsWith(`${item.href}/`)

            return (
              <Link
                key={item.name}
                href={item.href}
                className={cn(
                  "flex items-center px-4 py-3 text-sm font-medium rounded-md",
                  isActive ? "bg-primary text-white" : "text-gray-700 hover:bg-gray-100",
                )}
                onClick={onClose}
              >
                <item.icon className={cn("mr-3 h-5 w-5", isActive ? "text-white" : "text-gray-500")} />
                {item.name}
              </Link>
            )
          })}
        </nav>

        <div className="p-4 border-t">
          <button
            onClick={() => {
              logout()
              onClose()
            }}
            className="flex items-center w-full px-4 py-3 text-sm font-medium text-gray-700 rounded-md hover:bg-gray-100"
          >
            <LogOut className="mr-3 h-5 w-5 text-gray-500" />
            Sign Out
          </button>
        </div>
      </div>
    </div>
  )
}
