import { db } from "./config"
import { doc, getDoc } from "firebase/firestore"

export async function getNewsById(id: string) {
  const docRef = doc(db, "news", id)
  const docSnap = await getDoc(docRef)

  if (docSnap.exists()) {
    const data = docSnap.data()
    return {
      id: docSnap.id,
      ...data,
      publishDate: data.publishDate?.toDate(),
      createdAt: data.createdAt?.toDate(),
      updatedAt: data.updatedAt?.toDate(),
    }
  } else {
    throw new Error("News article not found")
  }
}
