# 読み込めないパッケージを洗い出す

# 開始時に読み込まれているパッケージのリスト
base_list <- search()

# インストールされている全パッケージを一つずつ試す
res <- lapply(
  .packages(all.available = TRUE),
  function(pkg){
    temp <- tryCatch(
        # 極力メッセージが表示されないようにパッケージを読み込む
        suppressMessages(
          library(pkg, character.only = TRUE, quietly = TRUE)
        ),
        # Warning, Error の場合はその内容を返す。改行はスペースに置換
        warning = function(w){
          return(c("Warning", gsub("\n", " ", w$message)))
        },
        error = function(e){
          return(c("Error"  , gsub("\n", " ", e$message)))
        }
    )
    
    # 初期状態と比較して、新しくロードされたものを detach() する
    sapply(setdiff(search(), base_list),
           function(p) detach(pos = match(p, search())))
    
    # パッケージのロード成功の場合は "ok" で返す
    if (pkg %in% temp){
      return(c(package = pkg,
               result  = "ok",
               message = "-"))
    } else {
      return(c(package = pkg,
               result  = temp[1],
               message = temp[2]))
    }
  })

# data frame に変換
res_df <- data.frame(Reduce(rbind, res), row.names = 1:length(res))

# 並べ替え
res_df$result <- factor(res_df$result, levels = c("Error", "Warning", "ok"))
res_df <- res_df[order(res_df$result, res_df$package),]

# 文字化け対策
res_df$message <- gsub("‘", "'", res_df$message)
res_df$message <- gsub("’", "'", res_df$message)

# CSVに結果を保存
write.csv(res_df, file = "~/library_test.csv")

# 読み込みに失敗したもの
res_df[res_df$result == "Warning",]
res_df[res_df$result == "Error",]
