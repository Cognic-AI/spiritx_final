import { db } from "./config"
import { doc, getDoc } from "firebase/firestore"

export async function getVerificationById(id: string) {
  const docRef = doc(db, "verifications", id)
  const docSnap = await getDoc(docRef)

  if (docSnap.exists()) {
    const data = docSnap.data()
    return {
      id: docSnap.id,
      ...data,
      createdAt: data.createdAt?.toDate(),
      updatedAt: data.updatedAt?.toDate(),
    }
  } else {
    throw new Error("Verification not found")
  }
}
