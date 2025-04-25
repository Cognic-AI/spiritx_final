import { db } from "./config"
import { doc, getDoc } from "firebase/firestore"

export async function getTechniqueById(id: string) {
  const docRef = doc(db, "education", id)
  const docSnap = await getDoc(docRef)

  if (docSnap.exists()) {
    const data = docSnap.data()
    return {
      id: docSnap.id,
      ...data,
      type: "technique",
      createdAt: data.createdAt?.toDate(),
      updatedAt: data.updatedAt?.toDate(),
      publishDate: data.publishDate?.toDate(),
    }
  } else {
    throw new Error("Technique not found")
  }
}

export async function getScienceArticleById(id: string) {
  const docRef = doc(db, "education", id)
  const docSnap = await getDoc(docRef)

  if (docSnap.exists()) {
    const data = docSnap.data()
    return {
      id: docSnap.id,
      ...data,
      type: "science",
      createdAt: data.createdAt?.toDate(),
      updatedAt: data.updatedAt?.toDate(),
      publishDate: data.publishDate?.toDate(),
    }
  } else {
    throw new Error("Science article not found")
  }
}
