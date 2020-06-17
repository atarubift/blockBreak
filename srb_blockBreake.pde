int gameflow;//ゲームの流れを管理する
int racket_x = 30; //ラケットのｘ座標
int racket_y = 300; //ラケットのy座標
int racket_w = 5; //ラケットの幅
int racket_h = 50; //ラケットの高さ
float ball_x; //ボールのｘ座標
float ball_y; //ボールのy座標
int ball_count;//ボールの残機
float ball_speedX; //x軸方向の移動
float ball_speedY; //y軸方向の移動
float ball_lastX; //飛んで来た方向のチェック（ｘ）
float ball_lastY; //飛んで来た方向のチェック（ｙ）
int bx;//ブロック描画用
int by;//ブロック描画用
int ball_dia = 12; // ボールの直径
int block_exist = 0; // ０->ブロック非表示、１->ブロック表示
int block_w = 20; // ブロックの幅
int block_h = 50; //ブロックの高さ
int [] block = new int[150]; //ブロック格納
int score; // 点数
int massage; //文章用
PImage img; //バックグラウンド画像



void setup() {
  size(1000, 700);
  game_setting();
  img = loadImage("NASA9.jpg");
}


void draw() {
  background(img);
  if (gameflow==0) {
    gameTitle();
  } else if (gameflow == 1) {
    gamePlay();
  } else {
    gameOver();
  }
}

//ゲームの値の初期化
void game_setting() {
  gameflow = 0;
  racket_w = 5;
  racket_h = 50;
  ball_x = racket_x + racket_w + ball_dia/2;
  ball_y = racket_y + racket_h/2;
  ball_speedX = 6;
  ball_speedY = random(random(-10, 10));
  for (int i=0; i<block.length; i++) {
    block[i] = 1;
  }
  block_exist = 0;
  score = 0;
  massage = 0;
  ball_count = 3;
}

//タイトル画面
void gameTitle() {
  racket_move();
  racket();
  showblock(bx, by);
  score_bar();
  massage++;
  if ((massage%60) <40) {
    textSize(20);
    fill(255, 0, 0);
    text("Click to start", 140, 360);
  }
}

//ゲームの実行
void gamePlay() {
  racket_move();
  racket();
  showblock(bx, by);
  ball();
  ball_move();
  score_bar();
}

//ゲームオーバーの実装
void gameOver() {
  racket();
  showblock(bx, by);
  score_bar();
  textSize(50);
  fill(255, 0, 0);
  text("GAME OVER", 60, 300);
  massage++;
  if ((massage%60) < 40) {
    textSize(20);
    fill(255, 0, 0);
    text("Click to retry!", 140, 360);
  }
}

//ラケットの描画
void racket() {
  fill(255);
  rect(racket_x, racket_y, racket_w, racket_h);
  //スコアが増えるとラケットの幅が狭まる
  if (score >= 1500) {
    racket_h = 40;
  }
  if (score >= 3000) {
    racket_h = 30;
  }
  if (score >= 4500) {
    racket_h = 20;
  }
}

//ラケットの操作
void racket_move() {
  racket_y=mouseY - racket_h/2;
  //ラケットが壁に当たった時の描写
  if (racket_y > height - racket_h) {
    racket_y = height - racket_h;
  }
  if (racket_y < 101) {
    racket_y = 101;
  }
}

//ボールの描画
void ball() {
  fill(255);
  ellipse(ball_x, ball_y, ball_dia, ball_dia);
}

//ボールの移動
void ball_move() {
  ball_lastX = ball_x;
  ball_lastY = ball_y;
  ball_x += ball_speedX;
  ball_y += ball_speedY;

  //壁との判定
  if (ball_x + ball_dia/2 > width) {
    ball_speedX *= -1;
  }
  if (ball_x - ball_dia/2 < 0) {
    ball_x = racket_x + racket_w + ball_dia/2;
    ball_y = racket_y + racket_h/2;
    ball_speedX = 3;
    ball_count -= 1;//残機を一つ減らす
  }
  if (ball_count == 0) {
    gameflow = 2;
  }

  if (ball_y + ball_dia/2 > height || ball_y -ball_dia/2 < 101) {
    ball_speedY *= -1;
  }

  //ラケットとの判定
  if (ball_y > racket_y && ball_y <racket_y + racket_h && ball_x == racket_x + racket_w) {
    ball_speedX = -ball_speedX;
    ball_speedY +=int(random(2))*2-1 ;
  }

  //ブロックとの判定
  if (block_exist == 0) {
    for (int i=0; i<block.length; i++) {
      block[i]=1;
    }
    score += 1000;//全消しで1000点
  }
}

//ブロックの描画
void showblock(int xx, int yy) {
  block_exist = 0;
  for (int i=0; i<block.length; i++) {
    if (block[i]==1) {
      fill((i/10)*15, 150, 150);
      xx = 650 + (i/10) * (block_w + 2);
      yy = (i%10) * (block_h + 2) + 145;
      checkHitBlock(i, xx, yy);
      if (block[i] == 1) {
        noStroke();
        rect(xx, yy, block_w, block_h);
        block_exist = 1;
      }
    }
  }
}

//ブロックの当たり判定
void checkHitBlock(int ii, int xx, int yy) {
  if (!((yy<ball_y)&&(yy+block_h>ball_y)&&(xx<ball_x)&&(xx+block_w>ball_x))) {
    return;
  }

  block[ii]=0;
  score += 100;

  if ((xx<ball_lastX) && (xx + block_w > ball_lastX)) {
    ball_speedY = -ball_speedY;
    return;
  }
  if ((yy<ball_lastY) && (yy+block_h > ball_lastY)) {
    ball_speedX = -ball_speedX;
    return;
  }
  ball_speedX = -ball_speedX;
  ball_speedY = -ball_speedY;
}

//画面上部の設定
void score_bar() {
  stroke(255);
  fill(0);
  rect(0, 0, width, 101);
  textSize(30);
  fill(255);
  text("score:" +score, 10, 50);
  text("×" +ball_count, 900, 50);
}

//マウスによる操作
void mousePressed() {
  if (gameflow == 0) {
    gameflow = 1;
  }
  if (gameflow == 2) {
    game_setting();
  }
}
