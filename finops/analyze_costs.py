import pandas as pd

df = pd.read_csv("aws-cost-sample.csv")

print("=" * 60)
print("1. COSTO TOTAL DEL MES")
print("=" * 60)
total = df["MonthlyCost"].sum()
print(f"Costo total: ${total:,.2f}")
print()

print("=" * 60)
print("2. COSTO POR SERVICIO (de mayor a menor)")
print("=" * 60)
by_service = df.groupby("Service")["MonthlyCost"].sum().sort_values(ascending=False)
for service, cost in by_service.items():
    pct = cost / total * 100
    print(f"  {service:<25} ${cost:>8,.2f} ({pct:5.1f}%)")
print()

print("=" * 60)
print("3. RECURSOS SIN ETIQUETAR (huecos de gobierno)")
print("=" * 60)
untagged = df[df["Environment"].isna() | df["CostCenter"].isna()]
print(f"Se encontraron {len(untagged)} recursos sin etiquetas completas, ")
print(f"por un total de ${untagged['MonthlyCost'].sum():,.2f}/mes:")
for _, row in untagged.iterrows():
    print(f"  - {row['ResourceId']:<30} ${row['MonthlyCost']:>7,.2f} ({row['Description']})")
print()

print("=" * 60)
print("4. CANDIDATOS A OPTIMIZACION (por palabras clave de desperdicio)")
print("=" * 60)
keywords = ["huerfano", "sin instancia", "poco trafico", "generacion anterior",
            "descontinuado", "minimo real", "sin ciclo de vida", "sin politica"]
mask = df["Description"].str.contains("|".join(keywords), case=False, na=False)
waste = df[mask]
print(f"Se encontraron {len(waste)} recursos con indicios de desperdicio, ")
print(f"por un total de ${waste['MonthlyCost'].sum():,.2f}/mes ", end="")
print(f"({waste['MonthlyCost'].sum() / total * 100:.1f}% del total):")
for _, row in waste.iterrows():
    print(f"  - {row['ResourceId']:<30} ${row['MonthlyCost']:>7,.2f} ({row['Description']})")
