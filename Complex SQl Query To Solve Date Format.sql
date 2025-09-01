-- CREATE OR REPLACE TABLE
--   `daton-candere.mis_team_view.Mktplace_Gsheet_Outamt` AS 
SELECT
  *
FROM (
  SELECT
    DATE(Payment_Date) AS Order_Date,
    Order__ID,
    Mkt_Order_ID,
    ROUND(Outstanding_Amount) AS Settled_Amount,
    MarketPlace_Name
  FROM (
    SELECT
      PARSE_DATE('%m-%d-%Y',REPLACE(REGEXP_EXTRACT(Payment_Date,r'\d+.\d+.\d+'),"/","-")) Payment_Date,
      Magento_Id AS Order__ID,
      "Null" AS Mkt_Order_ID,
      SUM(SAFE_CAST(Settled_Amount AS float64)) Outstanding_Amount,
      "Myntra" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.Myntra_outstanding_payment`
    GROUP BY
      1,
      2
    UNION ALL
    SELECT
      DATE(PD_Date) PD_Date,
      "Null" AS Magento_Id,
      TS_Order_ID,
      SUM(SAFE_CAST(PD_Settlement_Value AS float64)) PD_Settlement_Value,
      "Flipkart" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.Flipkart_outstanding_payment`
    GROUP BY
      1,
      3
    UNION ALL
    SELECT
      PARSE_DATE("%Y-%m-%d",CONCAT(Year,"-",Month,"-",Day)) order_date,
      Magento_Id,
      Mrk_order_id,
      final_payout,
      MarketPlace_Name
    FROM (
      SELECT
        *,
        (CASE
            WHEN order_date != REGEXP_EXTRACT(order_date,r'\d{4}') THEN REGEXP_EXTRACT(order_date,r'\d{4}')
          ELSE
          CONCAT("20",RIGHT(order_date,2))
        END
          ) Year,
        (CASE
            WHEN (CASE
              WHEN REPLACE((CASE
                  WHEN (CASE
                    WHEN order_date != REGEXP_EXTRACT(order_date,r'\d+$') THEN REGEXP_EXTRACT(order_date,r'\d{4}$')
                  ELSE
                  order_date
                END
                  ) IS NOT NULL THEN LEFT(order_date,2)
              END
                ),"-","") IS NULL THEN REPLACE(REGEXP_EXTRACT(SAFE_CAST(PARSE_DATE('%e-%b-%y',REGEXP_EXTRACT(order_date,r'\d+-\D{3}-\d+')) AS string),r'-\d{2}-'),"-","")
            ELSE
            REPLACE((CASE
                  WHEN (CASE
                    WHEN order_date != REGEXP_EXTRACT(order_date,r'\d+$') THEN REGEXP_EXTRACT(order_date,r'\d{4}$')
                  ELSE
                  order_date
                END
                  ) IS NOT NULL THEN LEFT(order_date,2)
              END
                ),"-","")
          END
            ) IS NULL THEN REPLACE(REGEXP_EXTRACT(order_date,r'-\d+-'),"-","")
          ELSE
          (CASE
              WHEN REPLACE((CASE
                  WHEN (CASE
                    WHEN order_date != REGEXP_EXTRACT(order_date,r'\d+$') THEN REGEXP_EXTRACT(order_date,r'\d{4}$')
                  ELSE
                  order_date
                END
                  ) IS NOT NULL THEN LEFT(order_date,2)
              END
                ),"-","") IS NULL THEN REPLACE(REGEXP_EXTRACT(SAFE_CAST(PARSE_DATE('%e-%b-%y',REGEXP_EXTRACT(order_date,r'\d+-\D{3}-\d+')) AS string),r'-\d{2}-'),"-","")
            ELSE
            REPLACE((CASE
                  WHEN (CASE
                    WHEN order_date != REGEXP_EXTRACT(order_date,r'\d+$') THEN REGEXP_EXTRACT(order_date,r'\d{4}$')
                  ELSE
                  order_date
                END
                  ) IS NOT NULL THEN LEFT(order_date,2)
              END
                ),"-","")
          END
            )
        END
          ) Month,
        (CASE
            WHEN (CASE
              WHEN REPLACE(REGEXP_EXTRACT(SAFE_CAST(PARSE_DATE('%e-%b-%y',REGEXP_EXTRACT(order_date,r'\d+-\D{3}-\d+')) AS string),r'-\d{2}-'),"-","") IS NOT NULL THEN REPLACE(LEFT(order_date,2),"-","")
            ELSE
            (CASE
                WHEN (CASE
                  WHEN order_date != REGEXP_EXTRACT(order_date,r'\d+$') THEN REGEXP_EXTRACT(order_date,r'\d{4}$')
                ELSE
                order_date
              END
                ) IS NOT NULL THEN REPLACE(REGEXP_EXTRACT(order_date,r'-\d+-'),"-","")
              ELSE
              (CASE
                  WHEN order_date != REGEXP_EXTRACT(order_date,r'\d+$') THEN REGEXP_EXTRACT(order_date,r'\d{4}$')
                ELSE
                order_date
              END
                )
            END
              )
          END
            ) IS NULL THEN REPLACE(REGEXP_EXTRACT(regexp_extract(order_date,
                r'\d+-\d+-\d+'),r'-\d+$'),"-","")
          ELSE
          (CASE
              WHEN REPLACE(REGEXP_EXTRACT(SAFE_CAST(PARSE_DATE('%e-%b-%y',REGEXP_EXTRACT(order_date,r'\d+-\D{3}-\d+')) AS string),r'-\d{2}-'),"-","") IS NOT NULL THEN REPLACE(LEFT(order_date,2),"-","")
            ELSE
            (CASE
                WHEN (CASE
                  WHEN order_date != REGEXP_EXTRACT(order_date,r'\d+$') THEN REGEXP_EXTRACT(order_date,r'\d{4}$')
                ELSE
                order_date
              END
                ) IS NOT NULL THEN REPLACE(REGEXP_EXTRACT(order_date,r'-\d+-'),"-","")
              ELSE
              (CASE
                  WHEN order_date != REGEXP_EXTRACT(order_date,r'\d+$') THEN REGEXP_EXTRACT(order_date,r'\d{4}$')
                ELSE
                order_date
              END
                )
            END
              )
          END
            )
        END
          ) Day
      FROM (
        SELECT
          REPLACE(order_date,"/","-") order_date,
          "Null" AS Magento_Id,
          eretail_orderno AS Mrk_order_id,
          SUM(SAFE_CAST(REPLACE(final_payout,",","") AS float64)) AS final_payout,
          "Nykaa" AS MarketPlace_Name
        FROM
          `daton-candere.mis_team_view.Nykaa_outstanding_payment`
        GROUP BY
          1,
          3))
    UNION ALL
    SELECT
      DATE(PARSE_TIMESTAMP('%d-%m-%Y %H:%M',Order_Date)) AS Order_Date,
      "Null" AS Magento_Id,
      CONCAT(REGEXP_EXTRACT(OrderID_SKU,r"^\d+"),"_",REGEXP_EXTRACT(OrderID_SKU,r"\w+-\w-\w+$")) Mkt_order_id,
      SUM(CAST(Sell_Price__unit AS float64)) Sell_Price_unit,
      "Pepperfry" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.Pepperfry_outstanding_payment`
    GROUP BY
      1,
      3
    UNION ALL
    SELECT
      PARSE_DATE('%d-%m-%Y',settlement_start_date) AS settlement_start_date,
      "Null" AS Magento_Id,
      order_id AS Mkt_Order_id,
      SUM(SAFE_CAST(price_amount AS float64)) price_amount,
      "Amazon" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.amazon_outstanding_pay_2021_2022`
    GROUP BY
      1,
      3
    UNION ALL
    SELECT
      PARSE_DATE('%d-%m-%Y',settlement_start_date) AS settlement_start_date,
      "Null" AS Magento_Id,
      order_id AS Mkt_Order_id,
      SUM(SAFE_CAST(amount AS float64)) price_amount,
      "Amazon" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.amazon_outstanding_pay_2022_2023`
    GROUP BY
      1,
      3
    UNION ALL
    SELECT
      DATE(PARSE_TIMESTAMP('%d-%m-%Y',REPLACE(REGEXP_EXTRACT(settlement_start_date,r'\d{2}.\d{2}.\d{4}'),".","-"))) settlement_start_date,
      "Null" AS Magento_Id,
      order_id AS Mkt_Order_id,
      SUM(SAFE_CAST(amount AS float64)) price_amount,
      "Amazon" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.amazon_outstanding_pay_2023_2024`
    GROUP BY
      1,
      3
    UNION ALL
    SELECT
      DATE(Settlement_Date) Settlement_Date,
      SAFE_CAST(Magnto_Id AS string) Magnto_Id,
      "Null" AS Mkt_Order_id,
      SUM(SAFE_CAST(Total_Seller_Payable AS float64)) Total_Seller_Payable,
      "Tatacliq" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.Tatacliq_outstanding_payment`
    GROUP BY
      1,
      2))
      
      
      
      
      
================================================================================================================================



CREATE OR REPLACE TABLE
  `daton-candere.mis_team_view.Mktplace_Gsheet_Outamt` AS
SELECT
  *
FROM (
  SELECT
    Order__ID,
    Mkt_Order_ID,
    ROUND(Outstanding_Amount) AS Settled_Amount,
    MarketPlace_Name
  FROM (
    SELECT
      Magento_Id AS Order__ID,
      "Null" AS Mkt_Order_ID,
      SUM(SAFE_CAST(Settled_Amount AS float64)) Outstanding_Amount,
      "Myntra" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.Myntra_outstanding_payment`
    GROUP BY
      1,
      2
    UNION ALL
    SELECT
      "Null" AS Magento_Id,
      TS_Order_ID,
      SUM(SAFE_CAST(PD_Settlement_Value AS float64)) PD_Settlement_Value,
      "Flipkart" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.Flipkart_outstanding_payment`
    GROUP BY
      1,
      2
    UNION ALL
    SELECT
      Magento_Id,
      Mrk_order_id,
      final_payout,
      MarketPlace_Name
    FROM (
      SELECT
        *
      FROM (
        SELECT
          "Null" AS Magento_Id,
          eretail_orderno AS Mrk_order_id,
          SUM(SAFE_CAST(REPLACE(final_payout,",","") AS float64)) AS final_payout,
          "Nykaa" AS MarketPlace_Name
        FROM
          `daton-candere.mis_team_view.Nykaa_outstanding_payment`
        GROUP BY
          1,
          2))
    UNION ALL
    SELECT
      "Null" AS Magento_Id,
      CONCAT(REGEXP_EXTRACT(OrderID_SKU,r"^\d+"),"_",REGEXP_EXTRACT(OrderID_SKU,r"\w+-\w-\w+$")) Mkt_order_id,
      SUM(CAST(Remittance_Recovery_Amount AS float64)) Remittance_Recovery_Amount,
      "Pepperfry" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.Pepperfry_outstanding_payment`
    GROUP BY
      1,
      2
    UNION ALL
    SELECT
      "Null" AS Magento_Id,
      order_id AS Mkt_Order_id,
      SUM(SAFE_CAST(price_amount AS float64)) price_amount,
      "Amazon" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.amazon_outstanding_pay_2021_2022`
    GROUP BY
      1,
      2
    UNION ALL
    SELECT
      "Null" AS Magento_Id,
      order_id AS Mkt_Order_id,
      SUM(SAFE_CAST(amount AS float64)) price_amount,
      "Amazon" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.amazon_outstanding_pay_2022_2023`
    GROUP BY
      1,
      2
    UNION ALL
    SELECT
      "Null" AS Magento_Id,
      order_id AS Mkt_Order_id,
      SUM(SAFE_CAST(amount AS float64)) price_amount,
      "Amazon" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.amazon_outstanding_pay_2023_2024`
    GROUP BY
      1,
      2
    UNION ALL
    SELECT
      SAFE_CAST(Magnto_Id AS string) Magento_Id,
      "Null" AS Mkt_Order_id,
      SUM(SAFE_CAST(Net_Payable AS float64)) Net_Payable,
      "Tatacliq" AS MarketPlace_Name
    FROM
      `daton-candere.mis_team_view.Tatacliq_outstanding_payment`
    GROUP BY
      1,
      2))