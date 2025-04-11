import 'package:sqflite/sqflite.dart';

Future<void> createAllTables(Database db) async {
  // 1) Tabla countries (para Country)
  await db.execute('''
    CREATE TABLE countries (
      id    INTEGER PRIMARY KEY AUTOINCREMENT,
      name  TEXT NOT NULL,
      code  TEXT NOT NULL UNIQUE
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

  // 3) Tabla intermedia country_currencies (para la relación N:M)
  await db.execute('''
    CREATE TABLE country_currencies (
      country_id  INTEGER NOT NULL,
      currency_id INTEGER NOT NULL,
      PRIMARY KEY (country_id, currency_id),
      FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE,
      FOREIGN KEY (currency_id) REFERENCES currencies(id) ON DELETE CASCADE
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
      budget_id    INTEGER NOT NULL,
      currency_id  INTEGER NOT NULL,
    
      FOREIGN KEY(budget_id) REFERENCES budgets(id) ON DELETE CASCADE,
      FOREIGN KEY(currency_id) REFERENCES currencies(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE trip_country (
      trip_id    INTEGER NOT NULL,
      country_id INTEGER NOT NULL,
      PRIMARY KEY (trip_id, country_id),
      FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
      FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE
    );
  ''');

  await db.execute('''
    CREATE TABLE transactions (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      type        INTEGER NOT NULL,   -- TransactionType.index
      date        INTEGER NOT NULL,   -- milisegundos
      description TEXT,
      amount      REAL NOT NULL,
      trip_id     INTEGER NOT NULL,
    
      FOREIGN KEY(trip_id) REFERENCES trips(id) ON DELETE CASCADE
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
      category                 INTEGER NOT NULL,  -- ExpenseCategory.index
      isAmortization           INTEGER NOT NULL DEFAULT 1,
      amortization             REAL,
      start_date_amortization  INTEGER,
      next_amortization_date   INTEGER,
      end_date_amortization    INTEGER,

      FOREIGN KEY(transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
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
      recurrent_income_type  INTEGER,  -- RecurrentIncomeType.index
      next_recurrent_date    INTEGER,
      active                 INTEGER DEFAULT 0,

      FOREIGN KEY(transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
    )
  ''');

  // 8) Tabla changes (para Chenge)
  //
  // Relación 1:1 con "transactions"
  // - currency_recived_id, currency_spent_id apuntan a "currencies"
  await db.execute('''
    CREATE TABLE changes (
      transaction_id      INTEGER PRIMARY KEY,
      currency_recived_id INTEGER NOT NULL,
      currency_spent_id   INTEGER NOT NULL,
      commission          REAL NOT NULL,
      amount_recived      REAL NOT NULL,

      FOREIGN KEY(transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
      FOREIGN KEY(currency_recived_id) REFERENCES currencies(id) ON DELETE CASCADE,
      FOREIGN KEY(currency_spent_id)   REFERENCES currencies(id) ON DELETE CASCADE
    )
  ''');

  // 9) Tabla oficial_rates (para CurrencyRate)
  await db.execute('''
    CREATE TABLE official_rates (
      id                  INTEGER PRIMARY KEY AUTOINCREMENT,
      currency_recived_id INTEGER NOT NULL,
      currency_spent_id   INTEGER NOT NULL,
      rate                REAL NOT NULL,

      FOREIGN KEY(currency_recived_id) REFERENCES currencies(id) ON DELETE CASCADE,
      FOREIGN KEY(currency_spent_id)   REFERENCES currencies(id) ON DELETE CASCADE
    )
  ''');
}
