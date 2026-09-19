// rust/src/api/simple.rs

pub struct TsumiItemData {
    pub id: String,
    pub title: String,
    pub url: String,
    pub created_at_epoch: i64, 
    pub is_rare: bool,
}

pub fn check_is_rotten(created_at_epoch: i64, current_epoch: i64) -> bool {
    let diff_millis = current_epoch - created_at_epoch;
    let diff_days = diff_millis / (1000 * 60 * 60 * 24);
    diff_days >= 7
}

pub fn calculate_consume_reward(is_rotten: bool, is_rare: bool) -> i32 {
    if is_rotten {
        -5
    } else if is_rare {
        20
    } else {
        10
    }
}

pub fn determine_if_rare(random_seed: i32) -> bool {
    random_seed % 5 == 0
}

