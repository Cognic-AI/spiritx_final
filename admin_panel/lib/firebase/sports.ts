import { db } from "./config"
import { doc, getDoc } from "firebase/firestore"

export async function getSportById(id: string) {
  const docRef = doc(db, "sports", id)
  const docSnap = await getDoc(docRef)

  if (docSnap.exists()) {
    return { id: docSnap.id, ...docSnap.data() }
  } else {
    throw new Error("Sport not found")
  }
}
