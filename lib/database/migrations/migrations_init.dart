import 'package:sqflite/sqflite.dart';

Future<void> createAllTables(Database db) async {
  // 1) Tabla countries (para Country)
  await db.execute('''
    CREATE TABLE countries (
      id        INTEGER PRIMARY KEY AUTOINCREMENT,
      name      TEXT NOT NULL,
      code      TEXT NOT NULL UNIQUE
    )
  ''');

  // 2) Tabla currencies (para Currency)
  await db.execute('''
    CREATE TABLE currencies (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      code            TEXT NOT NULL,
      name            TEXT NOT NULL,
      symbol          TEXT,
      symbol_native   TEXT,
      decimal_digits  INTEGER,
      rounding        INTEGER,
      name_plural     TEXT
    )
  ''');

  // 3) Tabla trips (para Trip)
  await db.execute('''
    CREATE TABLE trips (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      title        TEXT NOT NULL,
      description  TEXT,
      date_start   INTEGER NOT NULL,
      date_end     INTEGER,
      destination  TEXT NOT NULL,
      image        TEXT,
      open         INTEGER NOT NULL DEFAULT 1,
      country_id   INTEGER NOT NULL,
      budget_id    INTEGER NOT NULL,

      FOREIGN KEY(country_id) REFERENCES countries(id),
      FOREIGN KEY(budget_id) REFERENCES budgets(id)
    )
  ''');

  // 4) Tabla budgets (para Budget)
  await db.execute('''
    CREATE TABLE budgets (
      id             INTEGER PRIMARY KEY AUTOINCREMENT,
      max_limit      REAL NOT NULL,
      desired_limit  REAL NOT NULL,
      accumulated    REAL NOT NULL,
      limit_increase INTEGER NOT NULL DEFAULT 0
    )
  ''');

  // 5) Tabla transactions (BASE)
  //
  // Solo campos COMUNES a todas las transacciones:
  //  - type (TransactionType)
  //  - date
  //  - description
  //  - amount
  //  - trip_id
  //
  await db.execute('''
    CREATE TABLE transactions (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      type        INTEGER NOT NULL,   -- TransactionType.index
      date        INTEGER NOT NULL,   -- milisegundos
      description TEXT,
      amount      REAL NOT NULL,
      trip_id     INTEGER NOT NULL,

      FOREIGN KEY(trip_id) REFERENCES trips(id)
    )
  ''');

  // 6) Tabla expenses (para Expense)
  //
  // Relación 1:1 con "transactions"
  // - transaction_id = id de la transacción
  // - campos propios de Expense: category, amortization, ...
  //
  await db.execute('''
    CREATE TABLE expenses (
      transaction_id           INTEGER PRIMARY KEY,
      category                 INTEGER,  -- ExpenseCategory.index
      amortization             INTEGER NOT NULL DEFAULT 0,
      start_date_amortization  INTEGER,
      next_amortization_date   INTEGER,
      end_date_amortization    INTEGER,

      FOREIGN KEY(transaction_id) REFERENCES transactions(id)
    )
  ''');

  // 7) Tabla incomes (para Income)
  //
  // Relación 1:1 con "transactions"
  // - campos propios de Income
  await db.execute('''
    CREATE TABLE incomes (
      transaction_id         INTEGER PRIMARY KEY,
      is_recurrent           INTEGER,
      recurrent_income_type  INTEGER,
      next_recurrent_date    INTEGER,  -- milisegundos
      active                 INTEGER NOT NULL DEFAULT 1,

      FOREIGN KEY(transaction_id) REFERENCES transactions(id)
    )
  ''');

  // 8) Tabla chenges (para Chenge)
  //
  // Relación 1:1 con "transactions"
  // - currency_recived_id, currency_spent_id apuntan a "currencies"
  await db.execute('''
    CREATE TABLE chenges (
      transaction_id      INTEGER PRIMARY KEY,
      currency_recived_id INTEGER,
      currency_spent_id   INTEGER,
      amount_recived      REAL,

      FOREIGN KEY(transaction_id) REFERENCES transactions(id),
      FOREIGN KEY(currency_recived_id) REFERENCES currencies(id),
      FOREIGN KEY(currency_spent_id)   REFERENCES currencies(id)
    )
  ''');
}
