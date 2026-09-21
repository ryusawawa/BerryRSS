use flutter_rust_bridge::frb;

#[derive(Debug, Clone)]
pub struct RssNodeData {
    pub id: String,
    pub name: String,
    pub is_folder: bool,
    pub url: Option<String>,
    pub children: Vec<RssNodeData>,
    pub is_subscribed: bool,
}

#[derive(Debug, Clone)]
pub struct ArticleData {
    pub id: String,
    pub title: String,
    pub content: String,
    pub image_urls: Vec<String>,
}

#[frb(sync)]
pub fn greet(name: String) -> String {
    format!("BerryRSS Clean Engine initialized for {name}!")
}

pub fn process_and_save_article(url: String) -> Result<ArticleData, String> {
    Ok(ArticleData {
        id: url.clone(),
        title: "Cleaned Article Title".to_string(),
        content: format!("Cleaned content stripped of JS and Ads from: {url}"),
        image_urls: vec![],
    })
}
