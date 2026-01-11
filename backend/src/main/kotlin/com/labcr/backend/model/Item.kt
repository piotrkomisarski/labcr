package com.labcr.backend.model

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@Document(collection = "items")
data class Item(
    @Id val id: String? = null,
    val name: String,
    val description: String? = null,
    val createdAt: Instant = Instant.now()
)
