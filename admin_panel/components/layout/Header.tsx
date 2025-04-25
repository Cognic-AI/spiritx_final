"use client"

import { useState } from "react"
import { Menu, X } from "lucide-react"
import { useAuth } from "@/context/AuthContext"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import MobileSidebar from "./MobileSidebar"

export default function Header() {
  const [showMobileMenu, setShowMobileMenu] = useState(false)
  const { user, logout } = useAuth()

  const toggleMobileMenu = () => {
    setShowMobileMenu(!showMobileMenu)
  }

  return (
    <header className="bg-white border-b h-16 flex items-center justify-between px-4">
      <div className="md:hidden">
        <Button variant="ghost" size="icon" onClick={toggleMobileMenu}>
          {showMobileMenu ? <X /> : <Menu />}
        </Button>
        {showMobileMenu && <MobileSidebar onClose={() => setShowMobileMenu(false)} />}
      </div>

      <div className="flex-1 md:flex-initial"></div>

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" className="relative h-8 w-8 rounded-full">
            <Avatar className="h-8 w-8">
              <AvatarFallback>{user?.displayName?.charAt(0) || user?.email?.charAt(0) || "A"}</AvatarFallback>
            </Avatar>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuLabel>My Account</DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuItem onClick={logout}>Log out</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </header>
  )
}
