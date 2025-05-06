from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Invoice(BaseModel):
    id: int
    amount: float
    description: str

# stockage en mémoire (demo)
db = {}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/invoices/")
def create_invoice(inv: Invoice):
    db[inv.id] = inv
    return inv

@app.get("/invoices/{invoice_id}")
def read_invoice(invoice_id: int):
    return db.get(invoice_id, {"error": "not found"})

@app.put("/invoices/{invoice_id}")
def update_invoice(invoice_id: int, inv: Invoice):
    db[invoice_id] = inv
    return inv

@app.delete("/invoices/{invoice_id}")
def delete_invoice(invoice_id: int):
    return db.pop(invoice_id, {"error": "not found"})
