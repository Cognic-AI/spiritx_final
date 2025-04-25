import { verify } from "jsonwebtoken"

export async function verifyToken(token: string) {
  return new Promise((resolve, reject) => {
    verify(token, process.env.JWT_SECRET || "default_secret", (err, decoded) => {
      if (err) {
        reject(err)
      } else {
        resolve(decoded)
      }
    })
  })
}
