//
//  PostDetailRowView.swift
//  SocialTrailsApp
//
//  Created by Admin on 10/24/24.
//
import SwiftUI

struct PostDetailRowView: View {
    let post: UserPost
    @ObservedObject private var sessionManager = SessionManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                if let url = post.userprofilepicture, let imageUrl = URL(string: url) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.systemGray4))
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(.systemGray4))
                        .clipShape(Circle())
                }
              
                VStack(alignment: .leading) {
                    Text(post.username ?? "Unknown")
                        .font(.headline)
                    Text(post.location ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                if post.userId ==  sessionManager.getCurrentUser()?.id  {
                    Menu {
                        Button("Edit") {
                           
                        }
                        Button("Delete") {
                            
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                                .resizable()
                                .frame(width: 18, height: 4)
                                .foregroundColor(.primary)
                                .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 12)

            TabView {
                ForEach(post.uploadedImageUris ?? [], id: \.self) { imageUrl in
                    if let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width, height: 180)
                                .cornerRadius(10)
                        } placeholder: {
                            Image("noimage")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width, height: 180)
                                .cornerRadius(10)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .padding(.horizontal)
            .frame(height: 180)

            Text(post.captiontext)
               // .padding(.vertical, 5)
                .font(.body)

            HStack() {
                Button(action: {
                   
                }) {
                    Image(systemName: "heart")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                
                Text("\(post.likecount ?? 0)")
                    .font(.subheadline)

                Button(action: {
                   
                }) {
                    Image(systemName: "message")
                        .resizable()
                        .frame(width: 18, height: 18)
                }

                Text("\(post.commentcount ?? 0)")
                    .font(.subheadline)

                Spacer()
            }
            .padding(.vertical, 1)

            Text(Utils.getRelativeTime(from: post.createdon))
                .font(.footnote)
                .foregroundColor(.gray)
                //.padding(.top, 5)
        }
        .padding(5)
    }
}
