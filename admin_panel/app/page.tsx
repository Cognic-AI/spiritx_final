import { redirect } from "next/navigation"
import { cookies } from "next/headers"
import LoginForm from "@/components/auth/LoginForm"

export default async function Home() {
  // Check if user is already logged in
  const cookieStore = cookies()
  const authToken = (await cookieStore).get("auth_token")

  if (authToken) {
    redirect("/dashboard")
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-4 bg-gray-50">
      <div className="w-full max-w-md p-8 space-y-8 bg-white rounded-lg shadow-md">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-primary">Sri Lanka Sports</h1>
          <p className="mt-2 text-gray-600">Admin Panel</p>
        </div>
        <LoginForm />
      </div>
    </main>
  )
}
