pub fn get_backend_url() -> Option<String> {
    std::env::var("BACKEND_URL").ok().map(|url| {
        format!("{}", url.trim_end_matches('/'))
    })
}

pub fn get_environment() -> Option<String> {
    std::env::var("ENV").ok()
}